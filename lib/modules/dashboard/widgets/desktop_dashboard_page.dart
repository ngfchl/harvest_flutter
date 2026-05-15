import 'dart:collection';
import 'dart:math' as math;

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/cache/session_cache.dart';
import 'package:harvest/core/config/app_config.dart';
import 'package:harvest/core/http/api.dart';
import 'package:harvest/core/http/hooks.dart';
import 'package:harvest/core/provider/app_auto_refresh_provider.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/storage/storage_keys.dart';
import 'package:harvest/core/theme/app_surface.dart';
import 'package:harvest/core/theme/theme_provider.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/widgets/cache_status_banner.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../models/kv/kv.dart';
import '../../shell/provider/screenshot_provider.dart';
import '../../shell/widgets/shell_scaffold.dart';
import '../../site/provider/site_provider.dart';
import '../model/backend_service_status.dart';
import '../model/dashboard_data.dart';
import '../model/server_resource_status.dart';
import '../provider/backend_service_status_provider.dart';
import '../provider/dashboard_provider.dart';
import '../provider/privacy_provider.dart';
import '../provider/server_resource_provider.dart';
import 'dashboard_cache_clear_popover.dart';
import 'desktop_chart_config.dart';
import 'phone_chart_settings.dart';
import 'treemap.dart';

class _DesktopDashboardIconTooltip extends StatelessWidget {
  final String message;
  final Widget child;

  const _DesktopDashboardIconTooltip({
    required this.message,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => shadcn.showPopover<void>(
        context: context,
        handler: const shadcn.PopoverOverlayHandler(),
        alignment: Alignment.topCenter,
        anchorAlignment: Alignment.bottomCenter,
        offset: const Offset(0, 8),
        consumeOutsideTaps: false,
        builder: (context) =>
            _DesktopDashboardIconTooltipPanel(message: message),
      ),
      child: child,
    );
  }
}

class _DesktopDashboardIconTooltipPanel extends StatelessWidget {
  final String message;

  const _DesktopDashboardIconTooltipPanel({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final lines = message.split('\n');
    final title = lines.isNotEmpty ? lines.first : '详情';
    final body = lines.length > 1 ? lines.skip(1).toList() : const <String>[];

    return shadcn.ModalContainer(
      padding: EdgeInsets.all(theme.density.baseContentPadding * theme.scaling),
      child: SizedBox(
        width: 260,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.small.copyWith(
                      color: cs.foreground,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                shadcn.IconButton.ghost(
                  density: shadcn.ButtonDensity.compact,
                  icon: Icon(
                    shadcn.LucideIcons.x,
                    size: 15,
                    color: cs.mutedForeground,
                  ),
                  onPressed: () => shadcn.closeOverlay(context),
                ),
              ],
            ),
            if (body.isNotEmpty) ...[
              SizedBox(height: theme.density.baseGap * theme.scaling),
              ...body.map(
                (line) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    line,
                    style: theme.typography.xSmall.copyWith(
                      color: cs.mutedForeground,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DesktopDashboardPage extends ConsumerStatefulWidget {
  const DesktopDashboardPage({super.key});

  @override
  ConsumerState<DesktopDashboardPage> createState() =>
      _DesktopDashboardPageState();
}

class _DesktopDashboardPageState extends ConsumerState<DesktopDashboardPage> {
  _DashboardThemeTokens get _tokens => _DashboardThemeTokens.of(context);
  Color get _panel => _tokens.panel;
  Color get _panelSoft => _tokens.panelSoft;
  Color get _line => _tokens.line;
  Color get _text => _tokens.text;
  Color get _muted => _tokens.muted;
  bool get _isDark =>
      shadcn.Theme.of(context).colorScheme.brightness == Brightness.dark;
  Color get _cyan => _tokens.cyan;
  Color get _green => _tokens.green;
  Color get _amber => _tokens.amber;
  Color get _red => _tokens.red;
  Color get _blue => _tokens.blue;
  Color get _violet => _tokens.violet;
  Color get _orange => _tokens.orange;
  double get _bottomGap => _tokens.bottomGap;
  List<Color> get _treemapColors => _tokens.treemapColors;

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
  late int _treemapCount;
  late Map<String, bool> _chartVisibility;
  _ChartTooltipData? _trendTooltip;
  Offset? _trendTooltipPosition;
  bool _trendTooltipHovering = false;
  int _chartTooltipCloseSerial = 0;

  bool get _busy => _refreshingDashboard || _refreshingSites || _signingIn;

  void _scheduleChartTooltipClose(VoidCallback onClose) {
    final serial = ++_chartTooltipCloseSerial;
    Future<void>.delayed(const Duration(seconds: 5), () {
      if (!mounted || serial != _chartTooltipCloseSerial) return;
      onClose();
    });
  }

  @override
  void initState() {
    super.initState();
    _treemapCount = DashboardChartConfig.getDesktopTreemapCount();
    _chartVisibility = DashboardChartConfig.getVisibility();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardNotifierProvider.notifier).refresh();
      _syncDesktopMonitorCards(_chartVisibility);
      if (mounted) {
        ref.read(activeScrollControllerProvider.notifier).state =
            _scrollController;
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
    try {
      await ref.read(appAutoRefreshControllerProvider).refresh();
    } finally {
      _refreshController.finishRefresh();
    }
  }

  bool _isChartVisible(String id) => _chartVisibility[id] ?? true;

  bool _anyChartVisible(Iterable<String> ids) => ids.any(_isChartVisible);

  void _showChartSettings(BuildContext anchorContext) {
    shadcn.showDialog<void>(
      context: context,
      builder: (ctx) => ChartSettingsDialog(
        order: DashboardChartConfig.desktopOrder,
        visibility: _chartVisibility,
        chartHeight: DashboardChartConfig.defaultDesktopChartHeight,
        treemapCount: _treemapCount,
        defaultTreemapCount: DashboardChartConfig.defaultDesktopTreemapCount,
        allowReorder: false,
        showSizingControls: false,
        showTreemapCountControl: true,
        title: '桌面看板显示设置',
        onTreemapCountSaved: DashboardChartConfig.saveDesktopTreemapCount,
        onSaved: (_, visibility, __, treemapCount, ___) {
          ref
              .read(serverResourceIntervalProvider.notifier)
              .update(
                HiveManager.get<int>(StorageKeys.serverResourceInterval) ??
                    kDefaultServerResourceInterval,
              );
          ref
              .read(serverResourceDurationProvider.notifier)
              .update(
                HiveManager.get<int>(StorageKeys.serverResourceDuration) ??
                    kDefaultServerResourceDuration,
              );
          final autoStart =
              HiveManager.get<bool>(StorageKeys.serverResourceAutoStart) ??
              kDefaultServerResourceAutoStart;
          ref.read(serverResourceAutoStartProvider.notifier).update(autoStart);
          _syncDesktopMonitorCards(visibility);
          setState(() {
            _chartVisibility = visibility;
            _treemapCount = treemapCount;
          });
        },
      ),
    );
  }

  void _syncDesktopMonitorCards(Map<String, bool> visibility) {
    final showServerResource = visibility['desktopServerResource'] ?? true;
    final showServiceStatus = visibility['desktopServiceStatus'] ?? true;

    if (!showServerResource) {
      ref.read(serverResourceProvider.notifier).stop();
    } else if (!ref.read(serverResourceProvider).running) {
      ref.read(serverResourceProvider.notifier).start();
    }

    if (!showServiceStatus) {
      ref.read(backendServiceStatusProvider.notifier).stop();
    } else if (!ref.read(backendServiceStatusProvider).running) {
      ref.read(backendServiceStatusProvider.notifier).start();
    }
  }

  String _taskEndpoint(String api) =>
      api.endsWith('/') ? api.substring(0, api.length - 1) : api;

  Future<void> _refreshDashboard() async {
    if (_busy) return;
    setState(() => _refreshingDashboard = true);
    try {
      await ref.read(appAutoRefreshControllerProvider).refresh();
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

  String _serverHostLabel(String server, bool privacy) {
    final uri = Uri.tryParse(server);
    final host = uri?.host.isNotEmpty == true ? uri!.host : server;
    final port = uri?.hasPort == true ? ':${uri!.port}' : '';
    if (!privacy) return '$host$port';
    final maskedHost = host
        .split('.')
        .map((part) => _mask(part, true))
        .join('.');
    return '$maskedHost$port';
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

  String _monthKey(String date) =>
      date.length >= 7 ? date.substring(0, 7) : date;

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
    final tokens = _tokens;

    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(tokens.textScale)),
      child: AppBackground(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: appSurfaceColor(context, tokens.background),
            gradient: tokens.pageGradient,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: data == null
                    ? Center(
                        child: shadcn.CircularProgressIndicator(
                          size: tokens.size(18),
                        ),
                      )
                    : _buildBoard(
                        context,
                        data,
                        cacheInfo,
                        privacy,
                        refreshSerial,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoard(
    BuildContext context,
    DashboardData data,
    DataCacheInfo cacheInfo,
    bool privacy,
    int refreshSerial,
  ) {
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
            padding: _tokens.edgeLTRB(
              20,
              18,
              20,
              _bottomGap + ShellBottomSpacing.value(context),
            ),
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
                        margin: _tokens.edgeOnly(top: 10),
                      ),
                      if (_isChartVisible('desktopKpi')) ...[
                        _tokens.vGap(14),
                        _buildKpiStrip(data, constraints.crossAxisExtent),
                      ],
                      _tokens.vGap(14),
                      if (compact)
                        _buildCompactContent(data, privacy)
                      else
                        _buildWideContent(data, privacy),
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

  Widget _buildHeader(
    DashboardData data,
    DataCacheInfo cacheInfo,
    bool privacy,
  ) {
    final tokens = _tokens;
    return _panelContainer(
      padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
      child: Row(
        children: [
          Container(
            width: tokens.size(44),
            height: tokens.size(44),
            decoration: BoxDecoration(
              color: _cyan.withValues(alpha: 0.14),
              borderRadius: shadcn.Theme.of(context).borderRadiusMd,
              border: Border.all(color: _cyan.withValues(alpha: 0.42)),
            ),
            child: Icon(shadcn.LucideIcons.chartNoAxesCombined, color: _cyan),
          ),
          tokens.hGap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HARVEST DATA COMMAND CENTER',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _text,
                    fontSize: tokens.font(20),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                tokens.vGap(6),
                Text(
                  '${data.siteCount.toInt()} 个站点接入 · ${_cacheText(cacheInfo, data)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _muted,
                    fontSize: tokens.font(12),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          tokens.hGap(10),
          _headerAction(
            icon: shadcn.LucideIcons.refreshCw,
            label: _refreshingDashboard ? '刷新中' : '刷新',
            onTap: (_) => _refreshDashboard(),
          ),
          tokens.hGap(8),
          _headerAction(
            icon: shadcn.LucideIcons.database,
            label: _refreshingSites ? '执行中' : '站点数据',
            onTap: (_) => _refreshSiteData(),
          ),
          tokens.hGap(8),
          _headerAction(
            icon: shadcn.LucideIcons.checkCheck,
            label: _signingIn ? '签到中' : '签到',
            onTap: (_) => _signInSites(),
          ),
          tokens.hGap(8),
          _headerAction(
            icon: shadcn.LucideIcons.trash2,
            label: '清缓存',
            onTap: showDashboardCacheClearPopover,
          ),
          tokens.hGap(8),
          _headerAction(
            icon: shadcn.LucideIcons.slidersHorizontal,
            label: '模块',
            onTap: _showChartSettings,
          ),
          tokens.hGap(8),
          _headerAction(
            icon: privacy ? shadcn.LucideIcons.eyeOff : shadcn.LucideIcons.eye,
            label: privacy ? '隐私' : '明文',
            onTap: (_) => ref.read(privacyModeProvider.notifier).toggle(),
          ),
          tokens.hGap(8),
          _themeModeSegmentedControl(),
        ],
      ),
    );
  }

  Widget _themeModeSegmentedControl() {
    final mode = ref.watch(themeNotifierProvider).mode;
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final tokens = _tokens;

    return Container(
      height: tokens.size(38),
      padding: tokens.edgeAll(2),
      decoration: BoxDecoration(
        color: _panelSoft.withValues(alpha: 0.86),
        borderRadius: theme.borderRadiusMd,
        border: Border.all(color: _line.withValues(alpha: 0.92)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _themeModeSegment(
            mode: shadcn.ThemeMode.light,
            current: mode,
            icon: shadcn.LucideIcons.sun,
            label: '明',
            tooltip: '亮色模式',
            colors: cs,
          ),
          _themeModeSegment(
            mode: shadcn.ThemeMode.dark,
            current: mode,
            icon: shadcn.LucideIcons.moon,
            label: '暗',
            tooltip: '暗色模式',
            colors: cs,
          ),
          _themeModeSegment(
            mode: shadcn.ThemeMode.system,
            current: mode,
            icon: shadcn.LucideIcons.monitorCog,
            label: '自动',
            tooltip: '跟随系统',
            colors: cs,
          ),
        ],
      ),
    );
  }

  Widget _themeModeSegment({
    required shadcn.ThemeMode mode,
    required shadcn.ThemeMode current,
    required IconData icon,
    required String label,
    required String tooltip,
    required shadcn.ColorScheme colors,
  }) {
    final tokens = _tokens;
    final selected = current == mode;
    final theme = shadcn.Theme.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => ref.read(themeNotifierProvider.notifier).setMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        height: tokens.size(32),
        padding: tokens.edgeSymmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary
              : colors.background.withValues(alpha: 0),
          borderRadius: theme.borderRadiusSm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DesktopDashboardIconTooltip(
              message: tooltip,
              child: Icon(
                icon,
                size: tokens.size(14),
                color: selected ? colors.primaryForeground : _cyan,
              ),
            ),
            tokens.hGap(4),
            Text(
              label,
              style: TextStyle(
                color: selected ? colors.primaryForeground : _text,
                fontSize: tokens.font(12),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerAction({
    required IconData icon,
    required String label,
    required ValueChanged<BuildContext> onTap,
  }) {
    final tokens = _tokens;
    return Builder(
      builder: (buttonContext) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _busy ? null : () => onTap(buttonContext),
        child: Container(
          height: tokens.size(38),
          padding: tokens.edgeSymmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: _panelSoft.withValues(alpha: 0.86),
            borderRadius: shadcn.Theme.of(context).borderRadiusMd,
            border: Border.all(color: _line.withValues(alpha: 0.92)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: tokens.size(16), color: _cyan),
              tokens.hGap(6),
              Text(
                label,
                style: TextStyle(
                  color: _text,
                  fontSize: tokens.font(12),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiStrip(DashboardData data, double maxWidth) {
    final items = [
      _Kpi(
        '站点数',
        data.siteCount.toInt().toString(),
        '站点接入',
        _cyan,
        shadcn.LucideIcons.globe,
      ),
      _Kpi(
        '总上传',
        formatBytes(data.totalUploaded),
        '今日 +${formatBytes(data.todayUploadIncrement)}',
        _green,
        shadcn.LucideIcons.arrowUp,
      ),
      _Kpi(
        '总下载',
        formatBytes(data.totalDownloaded),
        '今日 +${formatBytes(data.todayDownloadIncrement)}',
        _red,
        shadcn.LucideIcons.arrowDown,
      ),
      _Kpi(
        '做种体积',
        formatBytes(data.totalSeedVol),
        '${_formatCount(data.totalSeeding)} 个做种',
        _blue,
        shadcn.LucideIcons.hardDrive,
      ),
      _Kpi(
        '做种数',
        _formatCount(data.totalSeeding),
        '活跃做种任务',
        _tokens.treemapColors[7],
        shadcn.LucideIcons.database,
      ),
      _Kpi(
        '下载中',
        _formatCount(data.totalLeeching),
        '正在下载任务',
        _orange,
        shadcn.LucideIcons.download,
      ),
      _Kpi(
        '发布总量',
        _formatCount(data.totalPublished),
        '累计发布种子',
        _amber,
        shadcn.LucideIcons.upload,
      ),
      _Kpi(
        'P龄',
        _accountAge(data),
        data.earliestSite?.site ?? '暂无站点',
        _violet,
        shadcn.LucideIcons.calendar,
      ),
    ];

    Widget row(List<_Kpi> rowItems) {
      final tokens = _tokens;
      return Row(
        children: [
          for (var i = 0; i < rowItems.length; i++) ...[
            if (i > 0) tokens.hGap(10),
            Expanded(
              child: _buildKpiTile(
                rowItems[i],
                onTap: rowItems[i].label == 'P龄'
                    ? () => setState(() => _showWeeks = !_showWeeks)
                    : null,
              ),
            ),
          ],
        ],
      );
    }

    if (maxWidth >= 1080) {
      return Column(
        children: [
          row(items.take(4).toList()),
          _tokens.vGap(10),
          row(items.skip(4).toList()),
        ],
      );
    }
    return Column(
      children: [
        row(items.take(2).toList()),
        _tokens.vGap(10),
        row(items.skip(2).take(2).toList()),
        _tokens.vGap(10),
        row(items.skip(4).take(2).toList()),
        _tokens.vGap(10),
        row(items.skip(6).toList()),
      ],
    );
  }

  Widget _buildKpiTile(_Kpi item, {VoidCallback? onTap}) {
    final tokens = _tokens;
    final content = _panelContainer(
      height: 128,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(item.icon, color: item.color, size: tokens.size(18)),
              tokens.hGap(7),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _muted,
                    fontSize: tokens.font(12),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (onTap != null)
                SizedBox.square(
                  dimension: tokens.size(26),
                  child: shadcn.IconButton.ghost(
                    onPressed: onTap,
                    icon: Icon(
                      shadcn.LucideIcons.refreshCw,
                      size: tokens.size(14),
                      color: item.color,
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _kpiValue(item),
            ),
          ),
          Text(
            item.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _muted,
              fontSize: tokens.font(11),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    return content;
  }

  Widget _kpiValue(_Kpi item) {
    final tokens = _tokens;
    return SizedBox(
      width: double.infinity,
      child: FittedBox(
        alignment: Alignment.centerLeft,
        fit: BoxFit.scaleDown,
        child: Text(
          item.value,
          maxLines: 1,
          style: TextStyle(
            color: _isDark ? item.color : Color.lerp(item.color, _text, 0.18),
            fontSize: tokens.font(34),
            fontWeight: FontWeight.w900,
            height: 1,
            shadows: [
              Shadow(
                color: item.color.withValues(alpha: _isDark ? 0.36 : 0.46),
                blurRadius: _isDark ? 13 : 16,
              ),
              if (!_isDark)
                Shadow(
                  color: _tokens.background.withValues(alpha: 0.95),
                  blurRadius: 2,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWideContent(DashboardData data, bool privacy) {
    final tokens = _tokens;
    final showTrend = _isChartVisible('desktopTrend');
    final showDesignation = _isChartVisible('desktopDesignation');
    final showResource = _isChartVisible('desktopResource');
    final showServerResource = _isChartVisible('desktopServerResource');
    final showServiceStatus = _isChartVisible('desktopServiceStatus');
    final showStatus = _isChartVisible('desktopStatus');
    final showUploaded = _isChartVisible('desktopUploadShare');
    final showSeed = _isChartVisible('desktopSeedShare');
    final showAccount = _isChartVisible('desktopAccount');
    final showToday = _isChartVisible('desktopToday');
    final showRank = _isChartVisible('desktopRank');
    final showPublished = _isChartVisible('desktopMonthlyPublish');

    return Column(
      children: [
        if (showTrend || showToday) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showTrend)
                Expanded(flex: 7, child: _buildTrendPanel(data, privacy)),
              if (showTrend && showToday) tokens.hGap(10),
              if (showToday)
                Expanded(
                  flex: 4,
                  child: _buildTodayPanel(data, privacy, height: 390),
                ),
            ],
          ),
          tokens.vGap(10),
        ],
        if (showStatus || showDesignation || showResource) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showStatus)
                Expanded(
                  flex: 7,
                  child: _buildStatusTreemapPanel(data, privacy, height: 440),
                ),
              if (showStatus && (showDesignation || showResource))
                tokens.hGap(10),
              if (showDesignation || showResource)
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      if (showDesignation)
                        _buildDesignationPanel(
                          data,
                          height: showResource ? 128 : 440,
                        ),
                      if (showDesignation && showResource) tokens.vGap(10),
                      if (showResource)
                        _buildResourcePanel(
                          data,
                          height: showDesignation ? 302 : 440,
                        ),
                    ],
                  ),
                ),
            ],
          ),
          tokens.vGap(10),
        ],
        if (showUploaded || showSeed) ...[
          _buildDistributionRow(data, privacy, stacked: false),
          tokens.vGap(10),
        ],
        if (showServerResource || showServiceStatus || showAccount) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showServerResource || showServiceStatus)
                Expanded(
                  flex: showAccount ? 7 : 1,
                  child: Row(
                    children: [
                      if (showServerResource)
                        Expanded(child: _buildServerResourcePanel(height: 300)),
                      if (showServerResource && showServiceStatus)
                        tokens.hGap(10),
                      if (showServiceStatus)
                        Expanded(
                          child: _buildBackendServiceStatusPanel(height: 300),
                        ),
                    ],
                  ),
                ),
              if ((showServerResource || showServiceStatus) && showAccount)
                tokens.hGap(10),
              if (showAccount)
                Expanded(
                  flex: 4,
                  child: _buildAccountPanel(data, privacy, height: 300),
                ),
            ],
          ),
          tokens.vGap(10),
        ],
        if (showRank || showPublished) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showRank)
                Expanded(
                  flex: 7,
                  child: _buildRankPanel(data, privacy, height: 340),
                ),
              if (showRank && showPublished) tokens.hGap(10),
              if (showPublished)
                Expanded(
                  flex: 4,
                  child: _buildMonthlyPublishPanel(data, privacy, height: 340),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCompactContent(DashboardData data, bool privacy) {
    final tokens = _tokens;
    final showDesignation = _isChartVisible('desktopDesignation');
    final showTrend = _isChartVisible('desktopTrend');
    final showDistribution = _anyChartVisible(const [
      'desktopUploadShare',
      'desktopSeedShare',
    ]);
    final showStatus = _isChartVisible('desktopStatus');
    final showResource = _isChartVisible('desktopResource');
    final showServerResource = _isChartVisible('desktopServerResource');
    final showServiceStatus = _isChartVisible('desktopServiceStatus');
    final showRank = _isChartVisible('desktopRank');
    final showToday = _isChartVisible('desktopToday');
    final showPublished = _isChartVisible('desktopMonthlyPublish');
    final showAccount = _isChartVisible('desktopAccount');

    return Column(
      children: [
        if (showDesignation) ...[_buildDesignationPanel(data), tokens.vGap(10)],
        if (showTrend) ...[_buildTrendPanel(data, privacy), tokens.vGap(10)],
        if (showToday) ...[_buildTodayPanel(data, privacy), tokens.vGap(10)],
        if (showServerResource) ...[
          _buildServerResourcePanel(height: 320),
          tokens.vGap(10),
        ],
        if (showServiceStatus) ...[
          _buildBackendServiceStatusPanel(height: 250),
          tokens.vGap(10),
        ],
        if (showStatus) ...[
          _buildStatusTreemapPanel(data, privacy, height: 360),
          tokens.vGap(10),
        ],
        if (showDistribution) ...[
          _buildDistributionRow(data, privacy, stacked: true),
          tokens.vGap(10),
        ],
        if (showResource) ...[_buildResourcePanel(data), tokens.vGap(10)],
        if (showRank) ...[_buildRankPanel(data, privacy), tokens.vGap(10)],
        if (showPublished) ...[
          _buildMonthlyPublishPanel(data, privacy),
          tokens.vGap(10),
        ],
        if (showAccount) _buildAccountPanel(data, privacy),
      ],
    );
  }

  Widget _buildDesignationPanel(DashboardData data, {double height = 128}) {
    final tokens = _tokens;
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
              width: tokens.size(54),
              height: tokens.size(54),
              decoration: BoxDecoration(
                color: _red.withValues(alpha: 0.16),
                borderRadius: shadcn.Theme.of(context).borderRadiusMd,
                border: Border.all(color: _red.withValues(alpha: 0.42)),
              ),
              child: Icon(
                shadcn.LucideIcons.award,
                size: tokens.size(30),
                color: _red,
              ),
            ),
            tokens.hGap(12),
            _DesignationCard(
              designation: designation,
              siteCount: siteCount,
              width: tokens.size(190),
              height: tokens.size(48),
              fontSize: tokens.font(28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServerResourcePanel({required double height}) {
    final tokens = _tokens;
    final state = ref.watch(serverResourceProvider);
    final interval = ref.watch(serverResourceIntervalProvider);
    final duration = ref.watch(serverResourceDurationProvider);
    final remaining = ref.watch(serverResourceRemainingProvider);
    final privacy = ref.watch(privacyModeProvider);
    final data = state.data;
    final running = state.running;
    final statusText = state.error != null
        ? '连接失败'
        : running
        ? '监控中'
        : '已停止';
    final statusColor = state.error != null
        ? _red
        : running
        ? _green
        : _muted;
    final remainingText = running
        ? '${remaining ~/ 60}:${(remaining % 60).toString().padLeft(2, '0')}'
        : '${duration}min';
    final serverHost = _serverHostLabel(AppConfig.baseUrl, privacy);

    return _panelContainer(
      height: height,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: tokens.size(3),
                height: tokens.size(15),
                color: _cyan,
              ),
              tokens.hGap(8),
              Text(
                '服务器状态',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _text,
                  fontSize: tokens.font(15),
                  fontWeight: FontWeight.w900,
                ),
              ),
              tokens.hGap(12),
              Expanded(
                child: Text(
                  '$serverHost · ${interval}s · $remainingText',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _muted,
                    fontSize: tokens.font(11),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              tokens.hGap(10),
              Container(
                padding: tokens.edgeSymmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: shadcn.Theme.of(context).borderRadiusXl,
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.28),
                  ),
                ),
                child: Text(
                  statusText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: tokens.font(11),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              tokens.hGap(8),
              shadcn.IconButton.ghost(
                onPressed: () =>
                    ref.read(serverResourceProvider.notifier).toggle(),
                icon: Icon(
                  running ? shadcn.LucideIcons.pause : shadcn.LucideIcons.play,
                  size: tokens.size(15),
                  color: running ? _red : _green,
                ),
              ),
            ],
          ),
          tokens.vGap(10),
          SizedBox(
            height: tokens.size(88),
            child: Row(
              children: [
                Expanded(
                  child: _serverResourceMetric(
                    'CPU',
                    '${(data?.cpu.percent ?? 0).toStringAsFixed(1)}%',
                    '${(data?.cpu.limitCores ?? 0).toStringAsFixed(1)} 核',
                    _blue,
                    shadcn.LucideIcons.cpu,
                  ),
                ),
                tokens.hGap(10),
                Expanded(
                  child: _serverResourceMetric(
                    '内存',
                    '${(data?.memory.percent ?? 0).toStringAsFixed(1)}%',
                    '${formatBytes(data?.memory.workingSet ?? 0)} / ${formatBytes(data?.memory.limit ?? 0)}',
                    _violet,
                    shadcn.LucideIcons.memoryStick,
                  ),
                ),
                tokens.hGap(10),
                Expanded(
                  child: _serverResourceMetric(
                    '上传',
                    formatSpeed(data?.network.uploadSpeed ?? 0),
                    formatBytes(data?.network.bytesSent ?? 0),
                    _green,
                    shadcn.LucideIcons.arrowUp,
                  ),
                ),
                tokens.hGap(10),
                Expanded(
                  child: _serverResourceMetric(
                    '下载',
                    formatSpeed(data?.network.downloadSpeed ?? 0),
                    formatBytes(data?.network.bytesRecv ?? 0),
                    _red,
                    shadcn.LucideIcons.arrowDown,
                  ),
                ),
              ],
            ),
          ),
          tokens.vGap(10),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _serverResourceUsageChart(
                    title: 'CPU 占用',
                    value: data?.cpu.percent ?? 0,
                    history: state.history,
                    valueOf: (item) => item.cpu.percent,
                    color: _blue,
                  ),
                ),
                tokens.hGap(10),
                Expanded(
                  child: _serverResourceUsageChart(
                    title: '内存占用',
                    value: data?.memory.percent ?? 0,
                    displayValue:
                        '${formatBytes(data?.memory.workingSet ?? 0)} / ${formatBytes(data?.memory.limit ?? 0)} · ${(data?.memory.percent ?? 0).toStringAsFixed(1)}%',
                    history: state.history,
                    valueOf: (item) => item.memory.percent,
                    color: _violet,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _serverResourceUsageChart({
    required String title,
    required double value,
    required List<ServerResourceStatus> history,
    required double Function(ServerResourceStatus item) valueOf,
    required Color color,
    String? displayValue,
  }) {
    final tokens = _tokens;
    final points = _serverResourceUsagePoints(history, valueOf);
    final valueText = displayValue ?? '${value.toStringAsFixed(1)}%';

    return Container(
      padding: tokens.edgeLTRB(10, 9, 10, 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: shadcn.Theme.of(context).borderRadiusMd,
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _text,
                    fontSize: tokens.font(12),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              tokens.hGap(8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    valueText,
                    maxLines: 1,
                    style: TextStyle(
                      color: color,
                      fontSize: tokens.font(12),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          tokens.vGap(6),
          Expanded(
            child: points.isEmpty
                ? Center(
                    child: Text(
                      '等待数据',
                      style: TextStyle(
                        color: _muted,
                        fontSize: tokens.font(11),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : SfCartesianChart(
                    plotAreaBorderWidth: 0,
                    margin: EdgeInsets.zero,
                    primaryXAxis: CategoryAxis(
                      isVisible: false,
                      majorGridLines: const MajorGridLines(width: 0),
                    ),
                    primaryYAxis: NumericAxis(
                      minimum: 0,
                      maximum: 100,
                      interval: 50,
                      axisLine: const AxisLine(width: 0),
                      majorTickLines: const MajorTickLines(size: 0),
                      majorGridLines: MajorGridLines(
                        width: 0.6,
                        color: _line.withValues(alpha: 0.55),
                      ),
                      labelStyle: _axisStyle(),
                      axisLabelFormatter: (details) => ChartAxisLabel(
                        '${details.value.toInt()}%',
                        _axisStyle(),
                      ),
                    ),
                    series: <CartesianSeries>[
                      SplineAreaSeries<_ServerResourceUsagePoint, String>(
                        dataSource: points,
                        xValueMapper: (point, _) => point.label,
                        yValueMapper: (point, _) => point.value,
                        color: color.withValues(alpha: 0.18),
                        borderColor: color,
                        borderWidth: 2,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  List<_ServerResourceUsagePoint> _serverResourceUsagePoints(
    List<ServerResourceStatus> history,
    double Function(ServerResourceStatus item) valueOf,
  ) {
    return history.asMap().entries.map((entry) {
      final time = entry.value.timestamp;
      final label = time == null
          ? '${entry.key + 1}'
          : '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
      return _ServerResourceUsagePoint(
        label,
        valueOf(entry.value).clamp(0, 100).toDouble(),
      );
    }).toList();
  }

  Widget _serverResourceMetric(
    String label,
    String value,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    final tokens = _tokens;
    return Container(
      padding: tokens.edgeAll(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: shadcn.Theme.of(context).borderRadiusMd,
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showSubtitle = constraints.maxHeight >= tokens.size(58);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: tokens.size(14), color: color),
                  tokens.hGap(6),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _muted,
                        fontSize: tokens.font(11),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      maxLines: 1,
                      style: TextStyle(
                        color: color,
                        fontSize: tokens.font(16),
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
              if (showSubtitle)
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _muted,
                    fontSize: tokens.font(10),
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackendServiceStatusPanel({required double height}) {
    final tokens = _tokens;
    final state = ref.watch(backendServiceStatusProvider);
    final data = state.data;
    final summary = data?.summary ?? BackendServiceSummary.empty;
    final services = data?.services ?? const <BackendServiceInfo>[];
    final running = state.running;
    final statusText = _backendServiceStatusText(state);
    final statusColor = _backendServiceStatusColor(state);
    final updatedText = data?.timestamp == null
        ? (running ? '等待状态推送' : '监控已暂停')
        : '更新于 ${_formatDashboardTimeToSecond(data!.timestamp!)}';
    final subtitle = [
      if ((data?.source ?? '').isNotEmpty) data!.source,
      updatedText,
      if ((data?.connectionId ?? '').isNotEmpty) data!.connectionId,
    ].join(' · ');

    return _panelContainer(
      height: height,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: tokens.size(3),
                height: tokens.size(15),
                color: _green,
              ),
              tokens.hGap(8),
              Text(
                '后台服务状态',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _text,
                  fontSize: tokens.font(15),
                  fontWeight: FontWeight.w900,
                ),
              ),
              tokens.hGap(12),
              Expanded(
                child: Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _muted,
                    fontSize: tokens.font(11),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              tokens.hGap(10),
              Container(
                padding: tokens.edgeSymmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: shadcn.Theme.of(context).borderRadiusXl,
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.28),
                  ),
                ),
                child: Text(
                  statusText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: tokens.font(11),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              tokens.hGap(8),
              shadcn.IconButton.ghost(
                onPressed: () =>
                    ref.read(backendServiceStatusProvider.notifier).toggle(),
                icon: Icon(
                  running ? shadcn.LucideIcons.pause : shadcn.LucideIcons.play,
                  size: tokens.size(15),
                  color: running ? _red : _green,
                ),
              ),
            ],
          ),
          tokens.vGap(10),
          Row(
            children: [
              Expanded(
                child: _backendServiceSummaryCell('总数', summary.total, _text),
              ),
              tokens.hGap(8),
              Expanded(
                child: _backendServiceSummaryCell(
                  '运行',
                  summary.running,
                  _green,
                ),
              ),
              tokens.hGap(8),
              Expanded(
                child: _backendServiceSummaryCell(
                  '停止',
                  summary.stopped,
                  _amber,
                ),
              ),
              tokens.hGap(8),
              Expanded(
                child: _backendServiceSummaryCell('失败', summary.failed, _red),
              ),
            ],
          ),
          tokens.vGap(8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (state.error != null) {
                  return _backendServicePanelMessage(state.error!, _red);
                }
                if (services.isEmpty) {
                  return _backendServicePanelMessage(
                    running ? '正在等待后台服务状态推送' : '监控已暂停',
                    _muted,
                  );
                }

                final columns = constraints.maxWidth >= 720 ? 3 : 2;
                final rows = math.min(
                  3,
                  (services.length / columns).ceil().clamp(1, 3),
                );
                final rowExtent = rows <= 1
                    ? constraints.maxHeight
                    : ((constraints.maxHeight - tokens.size(8) * (rows - 1)) /
                              rows)
                          .clamp(tokens.size(42), tokens.size(56));
                final visibleServices = services
                    .take(math.min(services.length, columns * rows))
                    .toList();
                return GridView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: tokens.size(8),
                    mainAxisSpacing: tokens.size(8),
                    mainAxisExtent: rowExtent,
                  ),
                  itemCount: visibleServices.length,
                  itemBuilder: (context, index) =>
                      _backendServiceGridItem(visibleServices[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _backendServiceSummaryCell(String label, int value, Color color) {
    final tokens = _tokens;
    return Container(
      padding: tokens.edgeSymmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: shadcn.Theme.of(context).borderRadiusMd,
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _muted,
                fontSize: tokens.font(10),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '$value',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: tokens.font(15),
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _backendServiceGridItem(BackendServiceInfo service) {
    final tokens = _tokens;
    final color = _backendServiceStateColor(service.state);
    final uptime = _formatBackendServiceUptime(service.uptime);
    final detail = service.running && service.pid > 0
        ? '运行 $uptime · pid ${service.pid}'
        : service.description.isNotEmpty
        ? service.description
        : 'pid ${service.pid}';

    return Container(
      padding: tokens.edgeSymmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: _panelSoft.withValues(alpha: 0.72),
        borderRadius: shadcn.Theme.of(context).borderRadiusMd,
        border: Border.all(color: _line.withValues(alpha: 0.70)),
      ),
      child: Row(
        children: [
          Container(
            width: tokens.size(7),
            height: tokens.size(7),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          tokens.hGap(8),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 180,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      service.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _text,
                        fontSize: tokens.font(11),
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    tokens.vGap(3),
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _muted,
                        fontSize: tokens.font(9),
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          tokens.hGap(6),
          Text(
            service.state.isEmpty ? '-' : service.state,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: tokens.font(9),
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _backendServicePanelMessage(String text, Color color) {
    final tokens = _tokens;
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: tokens.edgeSymmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: shadcn.Theme.of(context).borderRadiusMd,
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: tokens.font(11),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _backendServiceStatusText(BackendServiceStatusState state) {
    if (state.error != null) return '连接失败';
    final data = state.data;
    if (data == null) return state.running ? '连接中' : '已停止';
    if (data.healthy) return '全部运行';
    if (data.hasIssue) return '有异常';
    return state.running ? '监控中' : '已停止';
  }

  Color _backendServiceStatusColor(BackendServiceStatusState state) {
    if (state.error != null) return _red;
    final data = state.data;
    if (data?.healthy == true) return _green;
    if (data?.hasIssue == true) return _amber;
    return state.running ? _green : _muted;
  }

  Color _backendServiceStateColor(String state) {
    switch (state.toUpperCase()) {
      case 'RUNNING':
        return _green;
      case 'STOPPED':
      case 'EXITED':
        return _amber;
      case 'FATAL':
      case 'FAILED':
      case 'BACKOFF':
        return _red;
      default:
        return _muted;
    }
  }

  String _formatBackendServiceUptime(int seconds) {
    if (seconds <= 0) return '0s';
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainSeconds = seconds % 60;
    if (days > 0) return '${days}d ${hours}h ${minutes}m ${remainSeconds}s';
    if (hours > 0) return '${hours}h ${minutes}m ${remainSeconds}s';
    if (minutes > 0) return '${minutes}m ${remainSeconds}s';
    return '${seconds}s';
  }

  String _formatDashboardTimeToSecond(DateTime time) {
    final local = time.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}:'
        '${local.second.toString().padLeft(2, '0')}';
  }

  _DesignationProgress _designationProgress(int siteCount) {
    final levels = _designations.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
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
                    primaryXAxis: CategoryAxis(
                      majorGridLines: const MajorGridLines(width: 0),
                      labelStyle: _axisStyle(),
                    ),
                    primaryYAxis: NumericAxis(
                      opposedPosition: false,
                      majorGridLines: MajorGridLines(
                        width: 0.7,
                        color: _line.withValues(alpha: 0.55),
                      ),
                      axisLine: const AxisLine(width: 0),
                      labelStyle: _axisStyle(),
                      axisLabelFormatter: (details) => ChartAxisLabel(
                        _formatYAxis(details.value),
                        _axisStyle(),
                      ),
                    ),
                    axes: [
                      NumericAxis(
                        name: 'daily',
                        opposedPosition: true,
                        majorGridLines: const MajorGridLines(width: 0),
                        axisLine: const AxisLine(width: 0),
                        labelStyle: _axisStyle(),
                        axisLabelFormatter: (details) => ChartAxisLabel(
                          _formatYAxis(details.value),
                          _axisStyle(),
                        ),
                      ),
                    ],
                    legend: Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                      textStyle: TextStyle(
                        color: _muted,
                        fontSize: _tokens.font(11),
                      ),
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
                        _scheduleTrendTooltip(
                          details,
                          month,
                          daily,
                          data,
                          privacy,
                        );
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
                        borderRadius: BorderRadius.vertical(
                          top: shadcn.Theme.of(context).radiusXsRadius,
                        ),
                      ),
                      ColumnSeries<_TrendPoint, String>(
                        name: '月下载',
                        dataSource: month,
                        xValueMapper: (p, _) => _formatMonth(p.label),
                        yValueMapper: (p, _) => p.downloaded,
                        color: _red.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.vertical(
                          top: shadcn.Theme.of(context).radiusXsRadius,
                        ),
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

  Widget _buildDistributionRow(
    DashboardData data,
    bool privacy, {
    required bool stacked,
  }) {
    final showUploaded = _isChartVisible('desktopUploadShare');
    final showSeed = _isChartVisible('desktopSeedShare');
    final tokens = _tokens;

    if (stacked) {
      return Column(
        children: [
          if (showUploaded) _buildUploadSharePanel(data, privacy),
          if (showUploaded && showSeed) tokens.vGap(10),
          if (showSeed) _buildSeedSharePanel(data, privacy),
        ],
      );
    }

    return Row(
      children: [
        if (showUploaded)
          Expanded(child: _buildUploadSharePanel(data, privacy)),
        if (showUploaded && showSeed) tokens.hGap(10),
        if (showSeed) Expanded(child: _buildSeedSharePanel(data, privacy)),
      ],
    );
  }

  Widget _buildStatusTreemapPanel(
    DashboardData data,
    bool privacy, {
    double height = 440,
  }) {
    final items =
        data.statusList.where((item) => item.value.uploaded > 0).toList()
          ..sort((a, b) => b.value.uploaded.compareTo(a.value.uploaded));

    return _boardPanel(
      title: '站点状态',
      subtitle: '上传体积矩形图 · 下载占比叠加',
      height: height,
      child: items.isEmpty
          ? _boardEmpty('暂无站点状态数据')
          : LayoutBuilder(
              builder: (context, constraints) {
                return TreemapSection(
                  data: items,
                  privacy: privacy,
                  height: constraints.maxHeight,
                  displayCount: _treemapCount,
                  colors: _treemapColors,
                );
              },
            ),
    );
  }

  Widget _buildUploadSharePanel(DashboardData data, bool privacy) {
    final items = _topStatus(
      data.statusList,
      privacy,
      (record) => record.value.uploaded,
      limit: 10,
    );
    return _boardPanel(
      title: '上传占比',
      subtitle: '累计上传分布 · 前十站点',
      height: 360,
      child: _distributionShareContent(
        items: items,
        baseColor: shadcn.Theme.of(context).colorScheme.primary,
        formatter: formatBytes,
      ),
    );
  }

  Widget _buildSeedSharePanel(DashboardData data, bool privacy) {
    final items = _seedAverageGroups(data.seedDataList, privacy);
    final legendItems = items.take(10).toList();
    return _boardPanel(
      title: '做种分布',
      subtitle: '低于平均做种量的站点已合并',
      height: 360,
      child: _distributionShareContent(
        items: items,
        legendItems: legendItems,
        baseColor: _green,
        formatter: formatBytes,
      ),
    );
  }

  Widget _distributionShareContent({
    required List<_NameValuePoint> items,
    List<_NameValuePoint>? legendItems,
    required Color baseColor,
    required String Function(num) formatter,
  }) {
    final tokens = _tokens;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;
        if (compact) {
          return Column(
            children: [
              SizedBox(
                height: tokens.size(150),
                child: _donutChart(items, baseColor, formatter: formatter),
              ),
              Container(
                height: tokens.size(1),
                margin: tokens.edgeSymmetric(vertical: 10),
                color: _line,
              ),
              Expanded(
                child: _rankList(
                  title: '图例前十',
                  items: legendItems ?? items,
                  color: baseColor,
                  formatter: formatter,
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              flex: 5,
              child: _donutChart(items, baseColor, formatter: formatter),
            ),
            Container(
              width: tokens.size(1),
              margin: tokens.edgeSymmetric(horizontal: 14),
              color: _line,
            ),
            Expanded(
              flex: 4,
              child: _rankList(
                title: '图例前十',
                items: legendItems ?? items,
                color: baseColor,
                formatter: formatter,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _donutChart(
    List<_NameValuePoint> items,
    Color baseColor, {
    required String Function(num) formatter,
  }) {
    final tokens = _tokens;
    if (items.isEmpty) {
      return _boardEmpty('暂无数据');
    }
    final total = items.fold<num>(0, (sum, item) => sum + item.value);
    late final TooltipBehavior tooltipBehavior;
    tooltipBehavior = TooltipBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      animationDuration: 0,
      duration: 5000,
      elevation: 24,
      opacity: 1,
      color: _panel,
      canShowMarker: false,
      builder: (dataPoint, point, series, pointIndex, seriesIndex) =>
          _donutTooltip(
            dataPoint,
            items,
            formatter,
            onClose: () => tooltipBehavior.hide(),
          ),
    );
    return SfCircularChart(
      margin: EdgeInsets.zero,
      tooltipBehavior: tooltipBehavior,
      annotations: [
        CircularChartAnnotation(
          widget: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatter(total),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _text,
                  fontSize: tokens.font(13),
                  fontWeight: FontWeight.w900,
                ),
              ),
              tokens.vGap(2),
              Text(
                '总计',
                style: TextStyle(
                  color: _muted,
                  fontSize: tokens.font(10),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
      series: <CircularSeries>[
        DoughnutSeries<_NameValuePoint, String>(
          dataSource: items,
          xValueMapper: (p, _) => p.name,
          yValueMapper: (p, _) => p.value,
          pointColorMapper: (_, index) => _palette(index, baseColor),
          radius: '86%',
          innerRadius: '62%',
          dataLabelSettings: const DataLabelSettings(isVisible: false),
        ),
      ],
    );
  }

  Widget _buildResourcePanel(DashboardData data, {double height = 300}) {
    final tokens = _tokens;
    return _boardPanel(
      title: '全局资源',
      subtitle: '全部站点实际指标',
      height: height,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _resourceMetric(
                    '总上传',
                    formatBytes(data.totalUploaded),
                    _green,
                    shadcn.LucideIcons.arrowUp,
                  ),
                ),
                tokens.hGap(8),
                Expanded(
                  child: _resourceMetric(
                    '总下载',
                    formatBytes(data.totalDownloaded),
                    _red,
                    shadcn.LucideIcons.arrowDown,
                  ),
                ),
              ],
            ),
          ),
          tokens.vGap(8),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _resourceMetric(
                    '做种体积',
                    formatBytes(data.totalSeedVol),
                    _blue,
                    shadcn.LucideIcons.hardDrive,
                  ),
                ),
                tokens.hGap(8),
                Expanded(
                  child: _resourceMetric(
                    '发布数',
                    _formatCount(data.totalPublished),
                    _amber,
                    shadcn.LucideIcons.upload,
                  ),
                ),
              ],
            ),
          ),
          tokens.vGap(8),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _resourceMetric(
                    '做种任务',
                    _formatCount(data.totalSeeding),
                    tokens.treemapColors[7],
                    shadcn.LucideIcons.database,
                  ),
                ),
                tokens.hGap(8),
                Expanded(
                  child: _resourceMetric(
                    '下载任务',
                    _formatCount(data.totalLeeching),
                    _orange,
                    shadcn.LucideIcons.download,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _resourceMetric(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    final tokens = _tokens;
    return Container(
      padding: tokens.edgeSymmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: _panelSoft.withValues(alpha: 0.58),
        borderRadius: shadcn.Theme.of(context).borderRadiusSm,
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(icon, size: tokens.size(15), color: color),
          tokens.hGap(8),
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
                      style: TextStyle(
                        color: _muted,
                        fontSize: tokens.font(10),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    tokens.vGap(3),
                    Text(
                      value,
                      maxLines: 1,
                      style: TextStyle(
                        color: color,
                        fontSize: tokens.font(17),
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
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
      return _ChartTooltipData(_formatDay(dailyPoint.label), rows);
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
      return _ChartTooltipData(_formatMonth(monthPoint.label), rows);
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

    return _chartTooltip(_formatMonth(dataPoint.label), rows, width: 250);
  }

  Widget _donutTooltip(
    dynamic dataPoint,
    List<_NameValuePoint> items,
    String Function(num) formatter, {
    VoidCallback? onClose,
  }) {
    if (dataPoint is! _NameValuePoint) {
      return const SizedBox.shrink();
    }

    final total = items.fold<num>(0, (sum, item) => sum + item.value);
    final percent = total <= 0 ? 0 : dataPoint.value / total * 100;
    return _chartTooltip(dataPoint.name, [
      _TooltipLine('数值', formatter(dataPoint.value), _cyan),
      _TooltipLine('占比', '${percent.toStringAsFixed(1)}%', _amber),
    ], onClose: onClose);
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
        segments.add(_TooltipSegment('  ', _muted));
      }
    }

    if (uploaded > 0) {
      segments.add(_TooltipSegment('↑${formatBytes(uploaded)}', uploadColor));
    }
    if (downloaded > 0) {
      addSpace();
      segments.add(
        _TooltipSegment('↓${formatBytes(downloaded)}', downloadColor),
      );
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
        rows.add(
          _TrendSitePoint(_mask(site.name, privacy), uploaded, downloaded, 0),
        );
      }
    }

    rows.sort(
      (a, b) =>
          (b.uploaded + b.downloaded).compareTo(a.uploaded + a.downloaded),
    );
    final visible = rows.length > limit ? rows.take(limit).toList() : rows;
    final hidden = rows.length - visible.length;
    return [
      for (final row in visible)
        if (_transferSegments(
              uploaded: row.uploaded,
              downloaded: row.downloaded,
              uploadColor: _cyan,
              downloadColor: _orange,
            )
            case final segments when segments.isNotEmpty)
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
        rows.add(
          _TrendSitePoint(
            _mask(site.name, privacy),
            uploaded,
            downloaded,
            published,
          ),
        );
      }
    }

    rows.sort(
      (a, b) =>
          (b.uploaded + b.downloaded).compareTo(a.uploaded + a.downloaded),
    );
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
            )
            case final segments when segments.isNotEmpty)
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
      for (final row in visible)
        _TooltipLine(row.name, formatter(row.value), _text),
      if (hidden > 0) _TooltipLine('其余', '$hidden 项', _muted),
    ];
  }

  Widget _chartTooltip(
    String title,
    List<_TooltipLine> rows, {
    double width = 220,
    double maxHeight = 240,
    VoidCallback? onClose,
  }) {
    final tokens = _tokens;
    final hasSummary = rows.isNotEmpty && rows.first.label == '汇总';
    final summary = hasSummary ? rows.first : null;
    final detailRows = hasSummary ? rows.skip(1).toList() : rows;
    final cs = shadcn.Theme.of(context).colorScheme;
    if (onClose != null) _scheduleChartTooltipClose(onClose);

    return Container(
      width: tokens.size(width),
      constraints: BoxConstraints(maxHeight: tokens.size(maxHeight)),
      padding: tokens.edgeSymmetric(horizontal: 10, vertical: 8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cs.popover,
        borderRadius: shadcn.Theme.of(context).borderRadiusMd,
        border: Border.all(color: cs.border.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: cs.foreground.withValues(alpha: 0.18),
            blurRadius: tokens.size(22),
            offset: Offset(0, tokens.size(8)),
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
                  style: TextStyle(
                    color: _text,
                    fontSize: tokens.font(12),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (summary != null) ...[
                tokens.hGap(12),
                _tooltipValue(summary, fontSize: tokens.font(11)),
              ],
              if (onClose != null) ...[
                tokens.hGap(8),
                shadcn.IconButton.ghost(
                  density: shadcn.ButtonDensity.compact,
                  icon: Icon(
                    shadcn.LucideIcons.x,
                    size: tokens.size(14),
                    color: _muted,
                  ),
                  onPressed: onClose,
                ),
              ],
            ],
          ),
          if (detailRows.isNotEmpty) ...[
            tokens.vGap(hasSummary ? 12 : 8),
            Flexible(
              fit: FlexFit.loose,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < detailRows.length; i++) ...[
                      if (i > 0) tokens.vGap(5),
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
    final tokens = _tokens;
    return Row(
      children: [
        Expanded(
          child: Text(
            row.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _muted,
              fontSize: tokens.font(11),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        tokens.hGap(12),
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
              style: TextStyle(
                color: row.color ?? _text,
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
              ),
            )
          : RichText(
              textAlign: TextAlign.right,
              text: TextSpan(
                children: [
                  for (final segment in row.segments)
                    TextSpan(
                      text: segment.text,
                      style: TextStyle(
                        color: segment.color,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildRankPanel(
    DashboardData data,
    bool privacy, {
    double height = 440,
  }) {
    final tokens = _tokens;
    final uploaded = _topStatus(
      data.statusList,
      privacy,
      (record) => record.value.uploaded,
      limit: 10,
    );
    final downloaded = _topStatus(
      data.statusList,
      privacy,
      (record) => record.value.downloaded,
      limit: 10,
    );
    return _boardPanel(
      title: '累计排行',
      subtitle: '站点上传/下载 TOP',
      height: height,
      child: Row(
        children: [
          Expanded(
            child: _rankList(
              title: '累计上传 TOP',
              items: uploaded,
              color: _green,
              formatter: formatBytes,
            ),
          ),
          Container(
            width: tokens.size(1),
            margin: tokens.edgeSymmetric(horizontal: 12),
            color: _line,
          ),
          Expanded(
            child: _rankList(
              title: '累计下载 TOP',
              items: downloaded,
              color: _red,
              formatter: formatBytes,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayPanel(
    DashboardData data,
    bool privacy, {
    double height = 360,
  }) {
    final tokens = _tokens;
    final upload = _topKv(data.uploadIncrementDataList, privacy, limit: 10);
    final download = _topKv(data.downloadIncrementDataList, privacy, limit: 10);
    final uploadAll = _topKv(data.uploadIncrementDataList, privacy, limit: 999);
    final downloadAll = _topKv(
      data.downloadIncrementDataList,
      privacy,
      limit: 999,
    );
    return _boardPanel(
      title: '今日增量',
      subtitle: '上传/下载增量结构与 TOP 明细',
      height: height,
      child: Column(
        children: [
          SizedBox(
            height: tokens.size(158),
            child: Row(
              children: [
                Expanded(
                  child: _todayIncrementDonutBlock(
                    title: '今日上传',
                    items: uploadAll,
                    total: data.todayUploadIncrement,
                    baseColor: _cyan,
                    icon: shadcn.LucideIcons.arrowUp,
                  ),
                ),
                Container(
                  width: tokens.size(1),
                  margin: tokens.edgeSymmetric(horizontal: 12),
                  color: _line,
                ),
                Expanded(
                  child: _todayIncrementDonutBlock(
                    title: '今日下载',
                    items: downloadAll,
                    total: data.todayDownloadIncrement,
                    baseColor: _orange,
                    icon: shadcn.LucideIcons.arrowDown,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: tokens.size(1),
            margin: tokens.edgeSymmetric(vertical: 12),
            color: _line,
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _rankList(
                    title: '上传 TOP',
                    items: upload,
                    color: _cyan,
                    formatter: formatBytes,
                  ),
                ),
                Container(
                  width: tokens.size(1),
                  margin: tokens.edgeSymmetric(horizontal: 12),
                  color: _line,
                ),
                Expanded(
                  child: _rankList(
                    title: '下载 TOP',
                    items: download,
                    color: _orange,
                    formatter: formatBytes,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _todayIncrementDonutBlock({
    required String title,
    required List<_NameValuePoint> items,
    required num total,
    required Color baseColor,
    required IconData icon,
  }) {
    final tokens = _tokens;
    final chartTotal = items.fold<num>(0, (sum, item) => sum + item.value);
    final displayTotal = chartTotal > 0 ? chartTotal : total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: tokens.size(14), color: baseColor),
            tokens.hGap(6),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _text,
                  fontSize: tokens.font(12),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        tokens.vGap(8),
        Expanded(
          child: _todayIncrementDonutChart(
            items: items,
            total: displayTotal,
            baseColor: baseColor,
          ),
        ),
      ],
    );
  }

  Widget _todayIncrementDonutChart({
    required List<_NameValuePoint> items,
    required num total,
    required Color baseColor,
  }) {
    final tokens = _tokens;
    if (items.isEmpty) {
      return Center(
        child: SizedBox.square(
          dimension: tokens.size(108),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _line.withValues(alpha: 0.72),
                    width: tokens.size(16),
                  ),
                ),
              ),
              Text(
                '无数据',
                style: TextStyle(
                  color: _muted,
                  fontSize: tokens.font(11),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      );
    }

    late final TooltipBehavior tooltipBehavior;
    tooltipBehavior = TooltipBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      animationDuration: 0,
      duration: 5000,
      elevation: 24,
      opacity: 1,
      color: _panel,
      canShowMarker: false,
      builder: (dataPoint, point, series, pointIndex, seriesIndex) =>
          _todayIncrementDonutTooltip(
            dataPoint,
            items,
            onClose: () => tooltipBehavior.hide(),
          ),
    );

    return SfCircularChart(
      margin: EdgeInsets.zero,
      tooltipBehavior: tooltipBehavior,
      annotations: [
        CircularChartAnnotation(
          widget: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatBytes(total),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _text,
                  fontSize: tokens.font(13),
                  fontWeight: FontWeight.w900,
                ),
              ),
              tokens.vGap(2),
              Text(
                '总计',
                style: TextStyle(
                  color: _muted,
                  fontSize: tokens.font(10),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
      series: <CircularSeries>[
        DoughnutSeries<_NameValuePoint, String>(
          dataSource: items,
          xValueMapper: (p, _) => p.name,
          yValueMapper: (p, _) => p.value,
          pointColorMapper: (_, index) => _palette(index, baseColor),
          radius: '86%',
          innerRadius: '62%',
          dataLabelSettings: const DataLabelSettings(isVisible: false),
        ),
      ],
    );
  }

  Widget _todayIncrementDonutTooltip(
    dynamic dataPoint,
    List<_NameValuePoint> items, {
    VoidCallback? onClose,
  }) {
    if (dataPoint is! _NameValuePoint) {
      return const SizedBox.shrink();
    }

    final total = items.fold<num>(0, (sum, item) => sum + item.value);
    final percent = total <= 0 ? 0 : dataPoint.value / total * 100;
    return _chartTooltip(dataPoint.name, [
      _TooltipLine('数值', formatBytes(dataPoint.value), _cyan),
      _TooltipLine('占比', '${percent.toStringAsFixed(1)}%', _amber),
    ], onClose: onClose);
  }

  Widget _buildMonthlyPublishPanel(
    DashboardData data,
    bool privacy, {
    double height = 300,
  }) {
    final items = _monthTrend(data);
    return _boardPanel(
      title: '月度发布',
      subtitle: '最近 12 个月发布走势',
      height: height,
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        margin: EdgeInsets.zero,
        primaryXAxis: CategoryAxis(
          majorGridLines: const MajorGridLines(width: 0),
          labelStyle: _axisStyle(),
        ),
        primaryYAxis: NumericAxis(
          majorGridLines: MajorGridLines(
            width: 0.7,
            color: _line.withValues(alpha: 0.55),
          ),
          axisLine: const AxisLine(width: 0),
          labelStyle: _axisStyle(),
          axisLabelFormatter: (details) =>
              ChartAxisLabel(_formatCount(details.value), _axisStyle()),
        ),
        trackballBehavior: TrackballBehavior(
          enable: true,
          activationMode: ActivationMode.singleTap,
          tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
          lineColor: _amber.withValues(alpha: 0.58),
          lineWidth: 1,
          tooltipSettings: const InteractiveTooltip(enable: false),
          builder: (context, details) =>
              _monthlyTrackballTooltip(details, items, data, privacy),
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
            borderRadius: BorderRadius.vertical(
              top: shadcn.Theme.of(context).radiusXsRadius,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountPanel(
    DashboardData data,
    bool privacy, {
    double height = 340,
  }) {
    final tokens = _tokens;
    final email = _topKv(data.emailCount, privacy, limit: 8);
    final username = _topKv(data.usernameCount, privacy, limit: 8);
    return _boardPanel(
      title: '账号分布',
      subtitle: '邮箱与用户名复用情况',
      height: height,
      child: Row(
        children: [
          Expanded(
            child: _rankList(
              title: '邮箱分布',
              items: email,
              color: _violet,
              formatter: _formatCount,
            ),
          ),
          Container(
            width: tokens.size(1),
            margin: tokens.edgeSymmetric(horizontal: 12),
            color: _line,
          ),
          Expanded(
            child: _rankList(
              title: '用户名分布',
              items: username,
              color: _blue,
              formatter: _formatCount,
            ),
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
    final tokens = _tokens;
    final maxValue = items.fold<num>(
      0,
      (max, item) => math.max(max, item.value),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: _text,
            fontSize: tokens.font(13),
            fontWeight: FontWeight.w900,
          ),
        ),
        tokens.vGap(12),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Text('暂无数据', style: TextStyle(color: _muted)),
                )
              : ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => tokens.vGap(10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final factor = maxValue > 0 ? item.value / maxValue : 0.0;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: tokens.size(22),
                              child: Text(
                                '${index + 1}'.padLeft(2, '0'),
                                style: TextStyle(
                                  color: index < 3 ? color : _muted,
                                  fontSize: tokens.font(12),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _text,
                                  fontSize: tokens.font(12),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            tokens.hGap(8),
                            Text(
                              formatter(item.value),
                              style: TextStyle(
                                color: _muted,
                                fontSize: tokens.font(11),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        tokens.vGap(5),
                        _boardProgressBar(factor, color),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _boardEmpty(String text) {
    final tokens = _tokens;
    return Center(
      child: Text(
        text,
        style: TextStyle(
          color: _muted,
          fontSize: tokens.font(12),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _boardProgressBar(num value, Color color) {
    final tokens = _tokens;
    return Container(
      height: tokens.size(4),
      decoration: BoxDecoration(
        color: _line.withValues(alpha: 0.55),
        borderRadius: shadcn.Theme.of(context).borderRadiusXs,
      ),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: value.clamp(0.0, 1.0).toDouble(),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: shadcn.Theme.of(context).borderRadiusXs,
          ),
        ),
      ),
    );
  }

  Widget _boardPanel({
    required String title,
    required String subtitle,
    required double height,
    required Widget child,
  }) {
    final tokens = _tokens;
    return _panelContainer(
      height: height,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: tokens.size(3),
                height: tokens.size(15),
                color: _cyan,
              ),
              tokens.hGap(8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _text,
                    fontSize: tokens.font(15),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _muted,
                  fontSize: tokens.font(11),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          tokens.vGap(10),
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
    final tokens = _tokens;
    final theme = shadcn.Theme.of(context);
    return Container(
      height: height == null ? null : tokens.size(height),
      padding: tokens.resolvePadding(padding),
      decoration: BoxDecoration(
        color: tokens.panel,
        gradient: tokens.panelGradient,
        borderRadius: theme.borderRadiusMd,
        border: Border.all(color: tokens.panelBorder),
        boxShadow: [
          BoxShadow(
            color: tokens.panelShadow,
            blurRadius: tokens.size(tokens.isDark ? 24 : 28),
            offset: Offset(0, tokens.size(10)),
          ),
          if (!tokens.isDark)
            BoxShadow(
              color: tokens.background.withValues(alpha: 0.80),
              blurRadius: 0,
              offset: Offset(0, tokens.size(1)),
              spreadRadius: -1,
            ),
        ],
      ),
      child: child,
    );
  }

  TextStyle _axisStyle() =>
      TextStyle(color: _muted, fontSize: _tokens.font(10));

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
        final old =
            map[record.createdAt] ?? _TrendPoint(record.createdAt, 0, 0, 0);
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
            .map(
              (record) =>
                  _NameValuePoint(_mask(record.name, privacy), valueOf(record)),
            )
            .where((item) => item.value > 0)
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    if (items.length <= limit) return items;
    return items.take(limit).toList();
  }

  List<_NameValuePoint> _topKv(List<KV> source, bool privacy, {int limit = 8}) {
    final items =
        source
            .map(
              (record) =>
                  _NameValuePoint(_mask(record.name, privacy), record.value),
            )
            .where((item) => item.value > 0)
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    if (items.length <= limit) return items;
    return items.take(limit).toList();
  }

  List<_NameValuePoint> _seedAverageGroups(List<KV> source, bool privacy) {
    final seeds = source.where((item) => item.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (seeds.isEmpty) return const [];

    final total = seeds.fold<num>(0, (sum, item) => sum + item.value);
    final average = total / seeds.length;
    final visible = seeds.where((item) => item.value >= average).toList();
    final belowAverage = seeds.where((item) => item.value < average).toList();
    final items = [
      for (final record in visible)
        _NameValuePoint(_mask(record.name, privacy), record.value),
    ];

    if (belowAverage.isNotEmpty) {
      items.add(
        _NameValuePoint(
          '低于平均 ${belowAverage.length} 个站点',
          belowAverage.fold<num>(0, (sum, item) => sum + item.value),
        ),
      );
    }

    return items;
  }

  Color _palette(int index, Color base) {
    final colors = [_cyan, _green, _amber, _red, _blue, _violet, _orange];
    if (index == 0) return base;
    return colors[index % colors.length];
  }
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

class _DesignationCardState extends State<_DesignationCard>
    with TickerProviderStateMixin {
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

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  List<Color> _colors(_DashboardThemeTokens tokens) {
    final palette = tokens.treemapColors;
    if (widget.siteCount >= 200) {
      return [tokens.amber, tokens.red, tokens.violet, tokens.amber];
    }
    if (widget.siteCount >= 150) {
      return [tokens.red, tokens.orange, tokens.amber, tokens.red];
    }
    if (widget.siteCount >= 100) {
      return [tokens.orange, tokens.amber, tokens.green, tokens.orange];
    }
    if (widget.siteCount >= 50) {
      return [tokens.blue, tokens.violet, tokens.red, tokens.blue];
    }
    if (widget.siteCount >= 30) {
      return [tokens.violet, tokens.red, tokens.violet];
    }
    if (widget.siteCount >= 20) {
      return [tokens.blue, tokens.violet, tokens.blue];
    }
    if (widget.siteCount >= 10) return [tokens.cyan, tokens.blue, tokens.cyan];
    return [tokens.green, tokens.cyan, palette.first];
  }

  @override
  Widget build(BuildContext context) {
    final tokens = _DashboardThemeTokens.of(context);
    final cs = tokens.cs;
    final typo = tokens.theme.typography;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showDialog(
        context: context,
        builder: (_) => Dialog(child: _buildPopoverContent(tokens, cs, typo)),
      ),
      child: Container(
        width: widget.width,
        height: widget.height,
        padding: tokens.edgeSymmetric(horizontal: 12),
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: widget.width - tokens.size(24),
          height: widget.height,
          child: _animatedDesignationText(
            fontSize: widget.fontSize,
            tokens: tokens,
          ),
        ),
      ),
    );
  }

  Widget _animatedDesignationText({
    required double fontSize,
    required _DashboardThemeTokens tokens,
  }) {
    return AnimatedBuilder(
      animation: _animCtrl,
      builder: (context, child) {
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: ShaderMask(
            shaderCallback: (bounds) {
              final colors = _colors(tokens);
              final stops = List.generate(
                colors.length,
                (i) => i / (colors.length - 1),
              );
              final offset = _animCtrl.value;
              final animatedStops =
                  stops.map((s) => (s + offset) % 1.0).toList()..sort();

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

  Widget _buildPopoverContent(
    _DashboardThemeTokens tokens,
    shadcn.ColorScheme cs,
    shadcn.Typography typo,
  ) {
    final entries = _designations.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    final progress = _unlockProgress();
    return Container(
      width: tokens.size(230),
      padding: tokens.edgeAll(12),
      decoration: BoxDecoration(
        color: appSurfaceColor(context, cs.background),
        borderRadius: shadcn.Theme.of(context).borderRadiusMd,
        border: Border.all(color: cs.border),
        boxShadow: [
          BoxShadow(
            color: cs.foreground.withValues(alpha: 0.1),
            blurRadius: tokens.size(12),
            offset: Offset(0, tokens.size(4)),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('称号等级', style: typo.small.copyWith(fontWeight: FontWeight.w600)),
          tokens.vGap(8),
          _buildUnlockProgress(tokens, cs, typo, progress),
          tokens.vGap(10),
          ...entries.map((entry) {
            final isActive = widget.siteCount >= entry.key;
            final isCurrent = widget.designation == entry.value;
            return Padding(
              padding: tokens.edgeSymmetric(vertical: 3),
              child: Row(
                children: [
                  Container(
                    width: tokens.size(6),
                    height: tokens.size(6),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? tokens.red
                          : (isActive ? tokens.green : cs.border),
                      shape: BoxShape.circle,
                    ),
                  ),
                  tokens.hGap(8),
                  SizedBox(
                    width: tokens.size(44),
                    child: Text(
                      '${entry.key}站',
                      style: typo.xSmall.copyWith(
                        color: isActive
                            ? cs.foreground
                            : cs.mutedForeground.withValues(alpha: 0.4),
                        fontSize: tokens.font(11),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isCurrent) ...[
                          Icon(
                            shadcn.LucideIcons.check,
                            size: tokens.size(13),
                            color: tokens.red,
                          ),
                          tokens.hGap(6),
                        ],
                        Flexible(
                          child: Text(
                            entry.value,
                            textAlign: TextAlign.right,
                            style: typo.xSmall.copyWith(
                              color: isCurrent
                                  ? tokens.red
                                  : (isActive
                                        ? cs.foreground
                                        : cs.mutedForeground.withValues(
                                            alpha: 0.4,
                                          )),
                              fontWeight: isCurrent
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                              fontSize: tokens.font(12),
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
    final levels = _designations.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
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

  Widget _buildUnlockProgress(
    _DashboardThemeTokens tokens,
    shadcn.ColorScheme cs,
    shadcn.Typography typo,
    _DesignationProgress progress,
  ) {
    return Container(
      padding: tokens.edgeAll(10),
      decoration: BoxDecoration(
        color: cs.muted.withValues(alpha: 0.18),
        borderRadius: shadcn.Theme.of(context).borderRadiusMd,
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
                style: typo.small.copyWith(
                  color: tokens.red,
                  fontWeight: FontWeight.w800,
                  fontSize: tokens.font(13),
                ),
              ),
              const Spacer(),
              Text(
                progress.completed
                    ? '已解锁最高称号'
                    : '距 ${progress.nextTitle} 还差 ${progress.remaining}站',
                style: typo.xSmall.copyWith(
                  color: cs.mutedForeground,
                  fontSize: tokens.font(11),
                ),
              ),
            ],
          ),
          tokens.vGap(8),
          Container(
            height: tokens.size(5),
            decoration: BoxDecoration(
              color: cs.border.withValues(alpha: 0.55),
              borderRadius: shadcn.Theme.of(context).borderRadiusXs,
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress.ratio.clamp(0.0, 1.0).toDouble(),
              child: Container(
                decoration: BoxDecoration(
                  color: tokens.red,
                  borderRadius: shadcn.Theme.of(context).borderRadiusXs,
                ),
              ),
            ),
          ),
          tokens.vGap(7),
          Text(
            progress.completed
                ? '当前称号：${progress.currentTitle}'
                : '${progress.currentLevel}站 ${progress.currentTitle} → ${progress.nextLevel}站 ${progress.nextTitle}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typo.xSmall.copyWith(
              color: cs.foreground,
              fontSize: tokens.font(11),
              fontWeight: FontWeight.w600,
            ),
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
    return _TrendPoint(
      label,
      uploaded ?? this.uploaded,
      downloaded ?? this.downloaded,
      published ?? this.published,
    );
  }
}

class _ServerResourceUsagePoint {
  final String label;
  final double value;

  const _ServerResourceUsagePoint(this.label, this.value);
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

  const _TrendSitePoint(
    this.name,
    this.uploaded,
    this.downloaded,
    this.published,
  );
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

  const _TooltipLine(this.label, this.value, [this.color])
    : segments = const [];

  const _TooltipLine.rich(this.label, this.segments) : value = '', color = null;

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

class _DashboardThemeTokens {
  final shadcn.ThemeData theme;
  final shadcn.ColorScheme cs;
  final bool isDark;
  final double densityScale;
  final double textScale;
  final Color background;
  final Color panel;
  final Color panelSoft;
  final Color line;
  final Color text;
  final Color muted;
  final Color cyan;
  final Color green;
  final Color amber;
  final Color red;
  final Color blue;
  final Color violet;
  final Color orange;

  _DashboardThemeTokens._({
    required this.theme,
    required this.cs,
    required this.isDark,
    required this.densityScale,
    required this.textScale,
    required this.background,
    required this.panel,
    required this.panelSoft,
    required this.line,
    required this.text,
    required this.muted,
    required this.cyan,
    required this.green,
    required this.amber,
    required this.red,
    required this.blue,
    required this.violet,
    required this.orange,
  });

  factory _DashboardThemeTokens.of(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final densityScale =
        ((theme.density.baseContainerPadding / 20.0) * theme.scaling).clamp(
          0.48,
          1.45,
        );
    final textScale = theme.scaling.clamp(0.82, 1.35);
    final accent = cs.primary;
    final danger = cs.destructive;
    final cool = _tone(
      accent,
      hueShift: isDark ? 18 : 10,
      saturationScale: 1.12,
    );
    final success = _tone(accent, hueShift: 120, saturationScale: 0.98);
    final warning = _tone(accent, hueShift: 62, saturationScale: 1.08);
    final info = _tone(accent, hueShift: -34, saturationScale: 1.04);
    final violet = _tone(accent, hueShift: -92, saturationScale: 0.98);
    final orange = _tone(danger, hueShift: 32, saturationScale: 1.02);

    return _DashboardThemeTokens._(
      theme: theme,
      cs: cs,
      isDark: isDark,
      densityScale: densityScale.toDouble(),
      textScale: textScale.toDouble(),
      background: appSurfaceColor(context, cs.background),
      panel: appSurfaceColor(context, cs.card),
      panelSoft: cs.muted,
      line: cs.border,
      text: cs.foreground,
      muted: cs.mutedForeground,
      cyan: cool,
      green: success,
      amber: warning,
      red: danger,
      blue: info,
      violet: violet,
      orange: orange,
    );
  }

  static Color _tone(
    Color color, {
    double hueShift = 0,
    double saturationScale = 1,
    double lightnessDelta = 0,
  }) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withHue((hsl.hue + hueShift) % 360)
        .withSaturation((hsl.saturation * saturationScale).clamp(0.22, 0.90))
        .withLightness((hsl.lightness + lightnessDelta).clamp(0.30, 0.70))
        .toColor();
  }

  double size(num value) => value * densityScale;

  double font(num value) => value * textScale;

  double get bottomGap => size(84);

  LinearGradient get pageGradient {
    return isDark
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [background, Color.lerp(background, panelSoft, 0.34)!],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(background, cyan, 0.08)!,
              background,
              Color.lerp(background, blue, 0.07)!,
            ],
          );
  }

  LinearGradient get panelGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: isDark
        ? [cs.card, Color.lerp(cs.card, panelSoft, 0.30)!]
        : [
            Color.lerp(cs.card, background, 0.55)!,
            Color.lerp(cs.card, cyan, 0.08)!,
          ],
  );

  Color get panelBorder => isDark
      ? line.withValues(alpha: 0.82)
      : Color.lerp(line, cyan, 0.30)!.withValues(alpha: 0.84);

  Color get panelShadow =>
      isDark ? text.withValues(alpha: 0.06) : cyan.withValues(alpha: 0.11);

  List<Color> get treemapColors => [
    cyan,
    green,
    amber,
    red,
    blue,
    violet,
    orange,
    _tone(green, hueShift: 28),
    _tone(violet, hueShift: 20),
    _tone(cyan, hueShift: -18),
    _tone(red, hueShift: -22, saturationScale: 0.9),
    muted,
  ];

  EdgeInsets edgeAll(num value) => EdgeInsets.all(size(value));

  EdgeInsets edgeLTRB(num left, num top, num right, num bottom) =>
      EdgeInsets.fromLTRB(size(left), size(top), size(right), size(bottom));

  EdgeInsets edgeOnly({
    num left = 0,
    num top = 0,
    num right = 0,
    num bottom = 0,
  }) => EdgeInsets.only(
    left: size(left),
    top: size(top),
    right: size(right),
    bottom: size(bottom),
  );

  EdgeInsets edgeSymmetric({num horizontal = 0, num vertical = 0}) =>
      EdgeInsets.symmetric(
        horizontal: size(horizontal),
        vertical: size(vertical),
      );

  EdgeInsetsGeometry resolvePadding(EdgeInsetsGeometry padding) {
    final resolved = padding.resolve(TextDirection.ltr);
    return EdgeInsets.fromLTRB(
      size(resolved.left),
      size(resolved.top),
      size(resolved.right),
      size(resolved.bottom),
    );
  }

  Widget vGap(num value) => SizedBox(height: size(value));

  Widget hGap(num value) => SizedBox(width: size(value));
}
