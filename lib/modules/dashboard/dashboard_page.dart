import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:harvest/core/cache/session_cache.dart';
import 'package:harvest/core/config/app_config.dart';
import 'package:harvest/core/http/api.dart';
import 'package:harvest/core/http/hooks.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/storage/storage_keys.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/widgets/cache_status_banner.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../auth/auth_provider.dart';
import '../models/kv/kv.dart';
import '../shell/provider/screenshot_provider.dart';
import '../shell/widgets/shell_scaffold.dart';
import '../site/provider/site_provider.dart';
import '../user/provider/user_management_provider.dart';
import 'model/backend_service_status.dart';
import 'model/dashboard_data.dart';
import 'model/server_resource_status.dart';
import 'provider/backend_service_status_provider.dart';
import 'provider/dashboard_provider.dart';
import 'provider/privacy_provider.dart';
import 'provider/server_resource_provider.dart';
import 'widgets/dashboard_chart_config.dart';
import 'widgets/dashboard_chart_settings.dart';
import 'widgets/desktop_dashboard_page.dart';
import 'widgets/treemap.dart';

part 'widgets/desktop_dashboard_view.dart';
part 'widgets/phone_dashboard_view.dart';

Color complementColor(Color color) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withHue((hsl.hue + 180) % 360).toColor();
}

String formatYAxis(num bytes) {
  if (bytes <= 0) return '0';
  if (bytes >= 1e12) return '${(bytes / 1e12).round()} TB';
  if (bytes >= 1e9) return '${(bytes / 1e9).round()} GB';
  if (bytes >= 1e6) return '${(bytes / 1e6).round()} MB';
  if (bytes >= 1e3) return '${(bytes / 1e3).round()} KB';
  return '${bytes.round()}';
}

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  static const double _bottomSafeGap = 88;
  static const int _phoneDashboardFetchDays = 30;
  static const int _phoneDistributionLimit = 10;
  static const _colors = [
    Color(0xFF6366F1),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFFEF4444),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFFF97316),
    Color(0xFF06B6D4),
    Color(0xFFEC4899),
    Color(0xFF84CC16),
    Color(0xFF14B8A6),
    Color(0xFFA855F7),
    Color(0xFFE11D48),
    Color(0xFF0EA5E9),
    Color(0xFFD946EF),
    Color(0xFF22D3EE),
    Color(0xFFFB923C),
    Color(0xFF4ADE80),
    Color(0xFF818CF8),
    Color(0xFFFBBF24),
    Color(0xFF78716C),
    Color(0xFF5EEAD4),
    Color(0xFFFDA4AF),
    Color(0xFF94A3B8),
    Color(0xFFA3E635),
    Color(0xFFE879F9),
    Color(0xFF67E8F9),
    Color(0xFF475569),
    Color(0xFF34D399),
    Color(0xFFFCA5A5),
    Color(0xFF60A5FA),
    Color(0xFFFBD38D),
    Color(0xFF86EFAC),
    Color(0xFFC4B5FD),
    Color(0xFFFDE68A),
    Color(0xFF6EE7B7),
    Color(0xFFF9A8D4),
    Color(0xFF7DD3FC),
    Color(0xFFD8B4FE),
    Color(0xFFD4D4D8),
  ];

  final Map<String, Set<int>> _hiddenSeries = {};
  late EasyRefreshController _refreshController;
  late List<String> _chartOrder;
  late Map<String, bool> _chartVisibility;
  late double _chartHeight;
  late int _treemapCount;
  final _scrollController = ScrollController();
  OverlayEntry? _dashboardTooltipEntry;
  Timer? _dashboardTooltipTimer;
  Offset? _dashboardTooltipPosition;
  bool _showAccountAgeWeeks = false;
  int _phoneTrendDays = 7;
  bool _isRefreshingDashboardData = false;
  bool _isRefreshingSiteData = false;
  bool _isSigningInSites = false;

  bool get _hasRunningSummaryAction =>
      _isRefreshingDashboardData || _isRefreshingSiteData || _isSigningInSites;

  bool _isHidden(String key, int index) =>
      _hiddenSeries[key]?.contains(index) ?? false;

  void _toggleHidden(String key, int index) {
    setState(() {
      _hiddenSeries.putIfAbsent(key, () => {});
      if (_hiddenSeries[key]!.contains(index)) {
        _hiddenSeries[key]!.remove(index);
      } else {
        _hiddenSeries[key]!.add(index);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshController = EasyRefreshController(controlFinishRefresh: true);
    _chartOrder = DashboardChartConfig.getOrder();
    _chartVisibility = DashboardChartConfig.getVisibility();
    _chartHeight = DashboardChartConfig.getChartHeight(); // ← 新增
    _treemapCount = DashboardChartConfig.getTreemapCount();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(dashboardNotifierProvider.notifier)
          .refresh(days: _phoneDashboardFetchDays);
      _syncPhoneMonitorCards(_chartVisibility);
      if (mounted) {
        ref.read(activeScrollControllerProvider.notifier).state =
            _scrollController;
      }
    });
  }

  void _showChartSettings({bool allowReorder = true}) {
    showDialog(
      context: context,
      builder: (ctx) => ChartSettingsDialog(
        order: _chartOrder,
        visibility: _chartVisibility,
        chartHeight: _chartHeight,
        treemapCount: _treemapCount,
        allowReorder: allowReorder,
        showSizingControls: allowReorder,
        onSaved: (order, visibility, height, treemapCount) {
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
          _syncPhoneMonitorCards(visibility);
          setState(() {
            if (allowReorder) _chartOrder = order;
            _chartVisibility = visibility;
            if (allowReorder) {
              _chartHeight = height;
              _treemapCount = treemapCount;
            }
          });
        },
      ),
    );
  }

  void _syncPhoneMonitorCards(Map<String, bool> visibility) {
    final showServerResource = visibility['phoneServerResource'] ?? true;
    final showServiceStatus = visibility['phoneServiceStatus'] ?? true;

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

  @override
  void dispose() {
    _hideDashboardOverlayTooltip();
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await ref
        .read(dashboardNotifierProvider.notifier)
        .refresh(days: _phoneDashboardFetchDays);
    _refreshController.finishRefresh();
  }

  Future<void> _refreshDashboardData() async {
    if (_hasRunningSummaryAction) return;
    setState(() => _isRefreshingDashboardData = true);

    try {
      await ref
          .read(dashboardNotifierProvider.notifier)
          .refresh(days: _phoneDashboardFetchDays);
      Toast.success('刷新数据完成');
    } catch (e, st) {
      AppLogger.error('刷新首页数据失败', e, st);
      Toast.error('刷新数据失败');
    } finally {
      if (mounted) setState(() => _isRefreshingDashboardData = false);
    }
  }

  Future<void> _loadPhoneDashboardData({bool showErrorToast = true}) async {
    if (_hasRunningSummaryAction) return;
    setState(() => _isRefreshingDashboardData = true);
    try {
      await ref
          .read(dashboardNotifierProvider.notifier)
          .refresh(days: _phoneDashboardFetchDays);
    } catch (e, st) {
      AppLogger.error('刷新首页美化版数据失败', e, st);
      if (showErrorToast) Toast.error('切换数据范围失败');
    } finally {
      if (mounted) setState(() => _isRefreshingDashboardData = false);
    }
  }

  Future<void> _setPhoneTrendDays(int days) async {
    if (_phoneTrendDays == days) return;
    setState(() => _phoneTrendDays = days);
  }

  String _taskEndpoint(String api) =>
      api.endsWith('/') ? api.substring(0, api.length - 1) : api;

  Future<void> _refreshSiteData() async {
    if (_hasRunningSummaryAction) return;
    setState(() => _isRefreshingSiteData = true);

    try {
      await fetchBasic(_taskEndpoint(API.MYSITE_STATUS_OPERATE));
      await ref.read(siteInfoListProvider.notifier).refresh();
      await ref
          .read(dashboardNotifierProvider.notifier)
          .refresh(days: _phoneDashboardFetchDays);
      Toast.success('站点数据任务已执行');
    } catch (e, st) {
      AppLogger.error('执行站点数据刷新任务失败', e, st);
      Toast.error('站点数据刷新失败');
    } finally {
      if (mounted) setState(() => _isRefreshingSiteData = false);
    }
  }

  Future<void> _signInSites() async {
    if (_hasRunningSummaryAction) return;
    setState(() => _isSigningInSites = true);

    try {
      await fetchBasic(_taskEndpoint(API.MYSITE_SIGNIN_OPERATE));
      await ref.read(siteInfoListProvider.notifier).refresh();
      await ref
          .read(dashboardNotifierProvider.notifier)
          .refresh(days: _phoneDashboardFetchDays);
      Toast.success('站点签到任务已执行');
    } catch (e, st) {
      AppLogger.error('执行站点签到任务失败', e, st);
      Toast.error('站点签到失败');
    } finally {
      if (mounted) setState(() => _isSigningInSites = false);
    }
  }

  String _mask(String name, bool privacy) {
    if (!privacy) return name;
    if (name.length <= 1) return '*';
    if (name.length == 2) return '${name[0]}*';
    return '${name[0]}*${name[name.length - 1]}';
  }

  String _formatMonth(String date) {
    if (date.length < 7) return date;
    final month = int.tryParse(date.substring(5, 7)) ?? 0;
    if (month == 1) return '${date.substring(2, 4)}-${date.substring(5, 7)}';
    return '$month月';
  }

  String _formatDay(String date) {
    if (date.length >= 10) return date.substring(8);
    return date;
  }

  String _formatCount(num value) {
    if (value <= 0) return '0';
    if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(1)}M';
    if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(1)}K';
    return '${value.round()}';
  }

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

  String _getDesignation(num siteCount) {
    String result = '无称号';
    for (final entry in _designations.entries) {
      if (siteCount >= entry.key) result = entry.value;
    }
    return result;
  }

  String _formatAccountAgeYears(String? timeJoin) {
    if (timeJoin == null || timeJoin.isEmpty) return '0天';
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

  String _formatAccountAgeWeeks(String? timeJoin) {
    if (timeJoin == null || timeJoin.isEmpty) return '0天';
    try {
      return calcWeeksDays(timeJoin);
    } catch (_) {
      return '0天';
    }
  }

  // ———————————————— 构建单个图表（按 ID） ————————————————

  Widget? _buildChartById(String id, DashboardData data, bool privacy) {
    switch (id) {
      case 'status':
        return _buildStatusChart('站点状态', data.statusList, privacy);
      case 'email':
        return _buildEmailPieChart(data.emailCount, privacy);
      case 'username':
        return _buildUsernamePieChart(data.usernameCount, privacy);
      case 'uploaded':
        return _buildUploadedPieChart(data.statusList, privacy);
      case 'todayUpload':
        return _buildTodayUploadPieChart(data.uploadIncrementDataList, privacy);
      case 'todayDownload':
        return _buildTodayDownloadPieChart(
          data.downloadIncrementDataList,
          privacy,
        );
      case 'publishedCount':
        return _buildPublishedCountPieChart(data.statusList, privacy);
      case 'seed':
        return _buildSeedChart(data.seedDataList, privacy);
      case 'monthUpload':
        return _buildMonthUploadChart(
          data.uploadMonthIncrementDataList,
          privacy,
        );
      case 'monthDownload':
        return _buildMonthDownloadChart(
          data.uploadMonthIncrementDataList,
          privacy,
        );
      case 'monthPublished':
        return _buildMonthPublishedChart(
          data.uploadMonthIncrementDataList,
          privacy,
        );
      case 'dailyStack':
        return _buildDailyStackChart(
          '每日上传趋势',
          data.stackChartDataList,
          privacy,
        );
      default:
        return null;
    }
  }

  Widget _buildChartBoundary(Widget child) {
    return RepaintBoundary(child: child);
  }

  Widget _buildChartItem(String id, DashboardData data, bool privacy) {
    final chart = _buildChartById(id, data, privacy);
    if (chart == null) return const SizedBox.shrink();
    return _buildChartBoundary(chart);
  }

  TextStyle _chartAxisTextStyle() {
    final cs = FTheme.of(context).colors;
    return FTheme.of(context).typography.xs.copyWith(
      fontSize: 10,
      color: cs.mutedForeground.withValues(alpha: 0.72),
    );
  }

  Legend _chartLegend() => Legend(
    isVisible: true,
    position: LegendPosition.bottom,
    overflowMode: LegendItemOverflowMode.scroll,
    orientation: LegendItemOrientation.horizontal,
    textStyle: FTheme.of(context).typography.xs.copyWith(
      fontSize: 10,
      color: FTheme.of(context).colors.mutedForeground.withValues(alpha: 0.9),
    ),
    iconHeight: 8,
    iconWidth: 8,
    itemPadding: 12,
    padding: 6,
    toggleSeriesVisibility: true,
  );

  @override
  Widget build(BuildContext context) {
    if (!context.isMobile) return const DesktopDashboardPage();

    final data = ref.watch(dashboardNotifierProvider);
    final cacheInfo = ref.watch(dashboardCacheInfoProvider);
    final refreshSerial = ref.watch(dashboardRefreshSerialProvider);
    final privacy = ref.watch(privacyModeProvider);
    final isPhone = PlatformTool.isPhone();

    if (data == null) return Center(child: FProgress.circularIcon());

    return Stack(
      children: [
        isPhone
            ? _buildPhoneLayout(data, privacy, cacheInfo, refreshSerial)
            : _buildDesktopLayout(data, privacy, cacheInfo, refreshSerial),
        // 隐私开关
        Positioned(
          right: 12,
          bottom: _bottomSafeGap + ShellBottomSpacing.value(context),
          child: Column(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            children: [
              FButton.icon(
                style: FButtonStyle.ghost(),
                child: Icon(privacy ? FIcons.eyeOff : FIcons.eye),
                onPress: () => ref.read(privacyModeProvider.notifier).toggle(),
              ),
              FButton.icon(
                style: FButtonStyle.ghost(),
                child: const Icon(FIcons.slidersHorizontal),
                onPress: _showChartSettings,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _maskServerInfo(String server, bool privacy) {
    if (!privacy) return server;
    final uri = Uri.tryParse(server);
    if (uri == null || uri.host.isEmpty) return _mask(server, privacy);

    final maskedHost = uri.host
        .split('.')
        .map((part) => _mask(part, privacy))
        .join('.');
    final authority = uri.hasPort ? '$maskedHost:${uri.port}' : maskedHost;
    final path = uri.path.isEmpty ? '' : '/***';
    return uri.hasScheme
        ? '${uri.scheme}://$authority$path'
        : '$authority$path';
  }

  String _maskEmail(String email, bool privacy) {
    if (!privacy) return email;
    final parts = email.split('@');
    if (parts.length != 2) return _mask(email, privacy);
    return '${_mask(parts.first, privacy)}@${_maskServerInfo(parts.last, privacy)}';
  }

  String _dashboardAuthLabel(String key) {
    const labels = {
      'username': '用户名',
      'email': '邮箱',
      'expire': '到期时间',
      'time expire': '到期时间',
      'time_expire': '到期时间',
      'timeExpire': '到期时间',
      'expire_time': '到期时间',
      'expired_at': '到期时间',
      'expires_at': '到期时间',
      'pay': '授权额度',
      'invite': '邀请次数',
      'try_user': '试用用户',
      'marked': '备注',
      'token': '授权 Token',
      'active': '状态',
      'is_active': '状态',
    };
    return labels[key] ?? key;
  }

  bool _isDashboardAuthIdentityKey(String key) {
    final normalized = key.toLowerCase();
    return normalized == 'username' ||
        normalized == 'user_name' ||
        normalized == 'name' ||
        normalized == 'email' ||
        normalized == 'mail' ||
        normalized == 'user_email';
  }

  String _dashboardAuthValue(String key, dynamic value, bool privacy) {
    if (value == null) return '';
    if (value is bool) return value ? '有效' : '无效';
    if (value is Map) {
      return value.entries
          .where((entry) => !_isDashboardAuthIdentityKey(entry.key.toString()))
          .map(
            (entry) =>
                '${_dashboardAuthLabel(entry.key.toString())}: ${_dashboardAuthValue(entry.key.toString(), entry.value, privacy)}',
          )
          .where((value) => value.trim().isNotEmpty)
          .join('；');
    }
    if (value is List) {
      return value
          .map((item) => _dashboardAuthValue(key, item, privacy))
          .where((value) => value.trim().isNotEmpty)
          .join('，');
    }
    final text = value.toString();
    if (!privacy) return text;
    final lowerKey = key.toLowerCase();
    if (lowerKey.contains('token')) return _mask(text, privacy);
    if (lowerKey.contains('email') || text.contains('@')) {
      return _maskEmail(text, privacy);
    }
    return text;
  }

  dynamic _findDashboardAuthValue(dynamic data, Iterable<String> keys) {
    if (data is Map) {
      for (final key in keys) {
        if (data.containsKey(key)) return data[key];
      }
      for (final entry in data.entries) {
        final nested = _findDashboardAuthValue(entry.value, keys);
        if (nested != null) return nested;
      }
    }
    if (data is List) {
      for (final item in data) {
        final nested = _findDashboardAuthValue(item, keys);
        if (nested != null) return nested;
      }
    }
    return null;
  }

  List<MapEntry<String, String>> _dashboardAuthEntries(
    dynamic data,
    bool privacy,
  ) {
    if (data == null) return const [];
    if (data is Map) {
      return data.entries
          .where((entry) => entry.value != null)
          .where((entry) => !_isDashboardAuthIdentityKey(entry.key.toString()))
          .map(
            (entry) => MapEntry(
              _dashboardAuthLabel(entry.key.toString()),
              _dashboardAuthValue(entry.key.toString(), entry.value, privacy),
            ),
          )
          .where((entry) => entry.value.trim().isNotEmpty)
          .toList();
    }
    if (data is List) {
      final value = data
          .map((item) => _dashboardAuthValue('auth', item, privacy))
          .where((value) => value.trim().isNotEmpty)
          .join('；');
      return value.isEmpty ? const [] : [MapEntry('授权信息', value)];
    }
    final value = _dashboardAuthValue('auth', data, privacy);
    return value.isEmpty ? const [] : [MapEntry('授权信息', value)];
  }

  String _dashboardAuthSummary(dynamic data, bool privacy) {
    if (data == null) return '暂无授权信息';
    final active = _findDashboardAuthValue(data, const ['active', 'is_active']);
    final expire = _findDashboardAuthValue(data, const [
      'time_expire',
      'time expire',
      'timeExpire',
      'expire',
      'expire_time',
      'expired_at',
      'expires_at',
    ]);
    final pay = _findDashboardAuthValue(data, const ['pay']);
    final invite = _findDashboardAuthValue(data, const ['invite']);

    final parts = <String>[];
    if (active != null)
      parts.add('状态 ${_dashboardAuthValue('active', active, privacy)}');
    if (expire != null)
      parts.add('到期时间 ${_dashboardAuthValue('expire', expire, privacy)}');
    if (pay != null)
      parts.add('额度 ${_dashboardAuthValue('pay', pay, privacy)}');
    if (invite != null)
      parts.add('邀请 ${_dashboardAuthValue('invite', invite, privacy)}');
    if (parts.isNotEmpty) return parts.join(' · ');

    final entries = _dashboardAuthEntries(data, privacy).take(2).toList();
    if (entries.isEmpty) return '暂无授权信息';
    return entries
        .map((entry) => '${entry.key} ${entry.value.replaceAll('\n', ' ')}')
        .join(' · ');
  }

  DateTime? _parseDashboardAuthExpire(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is num) {
      final timestamp = value.toInt();
      if (timestamp <= 0) return null;
      return timestamp > 100000000000
          ? DateTime.fromMillisecondsSinceEpoch(timestamp)
          : DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    }

    final text = value.toString().trim();
    if (text.isEmpty) return null;
    final numeric = num.tryParse(text);
    if (numeric != null) return _parseDashboardAuthExpire(numeric);
    return DateTime.tryParse(text.replaceFirst(' ', 'T')) ??
        DateTime.tryParse(text);
  }

  bool _isDashboardAuthExpiringSoon(dynamic data) {
    final expire = _findDashboardAuthValue(data, const [
      'time_expire',
      'time expire',
      'timeExpire',
      'expire',
      'expire_time',
      'expired_at',
      'expires_at',
    ]);
    final expireAt = _parseDashboardAuthExpire(expire);
    if (expireAt == null) return false;
    final remaining = expireAt.difference(DateTime.now());
    return !remaining.isNegative && remaining.inDays < 15;
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

  bool _dashboardAuthHealthy(dynamic data) {
    if (data == null) return false;
    final active = _findDashboardAuthValue(data, const ['active', 'is_active']);
    if (active is bool) return active;
    if (active is String) {
      final normalized = active.toLowerCase();
      return normalized == 'true' ||
          normalized == '1' ||
          normalized == 'yes' ||
          normalized == 'active';
    }
    return true;
  }

  Widget _buildServerStatusPill({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.36)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerMetricTile({
    required IconData icon,
    required String label,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final cs = FTheme.of(context).colors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.muted.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.border.withValues(alpha: 0.34)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.mutedForeground,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: cs.foreground,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: cs.mutedForeground,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerBar(bool privacy) {
    final cs = FTheme.of(context).colors;
    final authState = ref.watch(authNotifierProvider);
    final authInfo = ref.watch(authInfoProvider);
    final user = authState.user;
    final username = user == null ? '未登录' : _mask(user.username, privacy);
    final role = user == null
        ? '未获取用户信息'
        : user.isSuperuser
        ? '超级管理员'
        : user.isStaff
        ? '管理员'
        : '普通用户';
    final userSubtitle = user == null ? '等待登录状态同步' : role;
    final authText = authInfo.when(
      data: (data) => _dashboardAuthSummary(data, privacy),
      loading: () => '授权信息加载中',
      error: (_, __) => '授权信息加载失败',
    );
    final showExpireWarning = authInfo.when(
      data: _isDashboardAuthExpiringSoon,
      loading: () => false,
      error: (_, __) => false,
    );
    final authStatusText = authInfo.when(
      data: (data) => _dashboardAuthHealthy(data) ? '授权有效' : '授权异常',
      loading: () => '授权校验中',
      error: (_, __) => '授权获取失败',
    );
    final statusColor = authInfo.when(
      data: (data) => _dashboardAuthHealthy(data)
          ? const Color(0xFF34D399)
          : const Color(0xFFF59E0B),
      loading: () => const Color(0xFF60A5FA),
      error: (_, __) => const Color(0xFFF87171),
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.border.withValues(alpha: 0.34)),
        boxShadow: [
          BoxShadow(
            color: cs.foreground.withValues(alpha: 0.09),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: -8,
          ),
          BoxShadow(
            color: cs.border.withValues(alpha: 0.30),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cs.primary.withValues(alpha: 0.16)),
                ),
                child: Icon(FIcons.user, size: 24, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '用户信息',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: cs.foreground,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                        ),
                        if (showExpireWarning) ...[
                          const SizedBox(width: 8),
                          _buildServerStatusPill(
                            label: '即将到期',
                            color: const Color(0xFFF59E0B),
                            icon: FIcons.circleAlert,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cs.mutedForeground,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              FButton.icon(
                style: FButtonStyle.ghost(),
                onPress: () async =>
                    ref.read(authNotifierProvider.notifier).logout(),
                child: Icon(FIcons.logOut, size: 16, color: cs.destructive),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildServerMetricTile(
                  icon: FIcons.user,
                  label: '登录用户',
                  title: username,
                  subtitle: userSubtitle,
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildServerMetricTile(
                  icon: FIcons.shieldCheck,
                  label: '授权信息',
                  title: showExpireWarning
                      ? '$authStatusText · 即将到期'
                      : authStatusText,
                  subtitle: authText,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ———————————————— 概览统计 ————————————————

  Widget _buildSummaryStats(DashboardData data) {
    final accountAge = _showAccountAgeWeeks
        ? _formatAccountAgeWeeks(data.earliestSite?.timeJoin)
        : _formatAccountAgeYears(data.earliestSite?.timeJoin);
    final designation = _getDesignation(data.siteCount);
    final lastRefresh = formatDateStringToMinute(data.updatedAt, empty: '-');

    final actionItems = [
      _StatItem(
        '站点数据',
        _isRefreshingSiteData ? '执行中' : '刷新任务',
        FIcons.refreshCw,
        const Color(0xFF06B6D4),
        onTap: _hasRunningSummaryAction ? null : _refreshSiteData,
        loading: _isRefreshingSiteData,
        action: true,
      ),
      _StatItem(
        '刷新数据',
        _isRefreshingDashboardData ? '刷新中' : '重新拉取',
        FIcons.rotateCw,
        const Color(0xFF3B82F6),
        onTap: _hasRunningSummaryAction ? null : _refreshDashboardData,
        loading: _isRefreshingDashboardData,
        action: true,
      ),
      _StatItem(
        '站点签到',
        _isSigningInSites ? '执行中' : '签到任务',
        FIcons.calendarCheck,
        const Color(0xFFF59E0B),
        onTap: _hasRunningSummaryAction ? null : _signInSites,
        loading: _isSigningInSites,
        action: true,
      ),
    ];
    final statItems = [
      _StatItem(
        '总上传',
        formatBytes(data.totalUploaded),
        FIcons.arrowUp,
        const Color(0xFF10B981),
      ),
      _StatItem(
        '总下载',
        formatBytes(data.totalDownloaded),
        FIcons.arrowDown,
        const Color(0xFFEF4444),
      ),
      _StatItem(
        '站点数',
        '${data.siteCount}',
        FIcons.globe,
        const Color(0xFF8B5CF6),
      ),
      _StatItem(
        '发种数',
        '${data.totalPublished}',
        FIcons.hardDrive,
        const Color(0xFF3B82F6),
      ),
      _StatItem(
        '做种量',
        formatBytes(data.totalSeedVol),
        FIcons.database,
        const Color(0xFF6366F1),
      ),
      _StatItem(
        '做种数',
        '${data.totalSeeding}',
        FIcons.hardDrive,
        const Color(0xFF3B82F6),
      ),
      // _StatItem('今日上传', formatBytes(data.todayUploadIncrement), FIcons.trendingUp, const Color(0xFFF59E0B)),
      _StatItem(
        'P龄',
        accountAge,
        FIcons.calendar,
        const Color(0xFF14B8A6),
        onTap: () =>
            setState(() => _showAccountAgeWeeks = !_showAccountAgeWeeks),
      ),
    ];
    final lastRefreshItem = _StatItem(
      '最后刷新',
      lastRefresh,
      FIcons.clock,
      const Color(0xFF64748B),
    );

    const spacing = 10.0;
    const minItemWidth = 150.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final maxPerRow =
            ((availableWidth + spacing) / (minItemWidth + spacing))
                .floor()
                .clamp(1, actionItems.length + statItems.length + 2)
                .toInt();
        final cards = [
          ...actionItems.map(_buildSummaryStatCard),
          ...statItems.map(_buildSummaryStatCard),
          // 称号（带 FPopover）
          SizedBox(
            height: 70,
            child: _DesignationCard(
              designation: designation,
              siteCount: data.siteCount.toInt(),
            ),
          ),
          _buildSummaryStatCard(lastRefreshItem),
        ];
        final rows = <Widget>[];
        for (var start = 0; start < cards.length; start += maxPerRow) {
          final rowItems = cards.skip(start).take(maxPerRow).toList();
          rows.add(
            Row(
              children: [
                for (var index = 0; index < rowItems.length; index++) ...[
                  Expanded(child: rowItems[index]),
                  if (index != rowItems.length - 1)
                    const SizedBox(width: spacing),
                ],
              ],
            ),
          );
          if (start + maxPerRow < cards.length) {
            rows.add(const SizedBox(height: spacing));
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        );
      },
    );
  }

  Widget _buildSummaryStatCard(_StatItem item) {
    final cs = FTheme.of(context).colors;
    final disabledAction = item.action && item.onTap == null && !item.loading;

    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cs.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cs.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  item.icon,
                  size: 15,
                  color: disabledAction
                      ? item.color.withValues(alpha: 0.45)
                      : item.color,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    item.label,
                    style: TextStyle(fontSize: 12, color: cs.mutedForeground),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (item.action) ...[
                  const Spacer(),
                  Text(
                    item.loading ? '执行中' : '点击执行',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: item.loading
                          ? item.color
                          : cs.mutedForeground.withValues(
                              alpha: disabledAction ? 0.35 : 0.7,
                            ),
                    ),
                  ),
                  if (!item.loading) ...[
                    const SizedBox(width: 2),
                    Icon(
                      FIcons.chevronRight,
                      size: 12,
                      color: cs.mutedForeground.withValues(
                        alpha: disabledAction ? 0.25 : 0.55,
                      ),
                    ),
                  ],
                ],
              ],
            ),
            const Spacer(),
            if (item.loading)
              Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: FProgress.circularIcon(),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      item.value,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            else
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  item.value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                    color: disabledAction
                        ? cs.foreground.withValues(alpha: 0.45)
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ———————————————— 卡片容器 ————————————————

  Widget _buildCard({
    required String title,
    required Widget child,
    Widget? legend,
  }) {
    final cs = FTheme.of(context).colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: cs.background.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: cs.border.withValues(alpha: 0.72),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.foreground.withValues(alpha: 0.09),
            blurRadius: 22,
            offset: const Offset(0, 10),
            spreadRadius: -8,
          ),
          BoxShadow(
            color: cs.border.withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  FIcons.chartNoAxesCombined,
                  size: 12,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: FTheme.of(
                    context,
                  ).typography.base.copyWith(fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
          if (legend != null) ...[const SizedBox(height: 6), legend],
        ],
      ),
    );
  }

  // ———————————————— 空状态 ————————————————

  Widget _buildEmptyPlaceholder(String title) {
    return _buildCard(
      title: title,
      child: SizedBox(
        height: _chartHeight,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FIcons.chartNoAxesCombined,
                size: 32,
                color: FTheme.of(
                  context,
                ).colors.mutedForeground.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 8),
              Text(
                '暂无数据',
                style: FTheme.of(context).typography.sm.copyWith(
                  color: FTheme.of(
                    context,
                  ).colors.mutedForeground.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ———————————————— 通用饼图 ————————————————

  Widget _buildPieChart({
    required String title,
    required List<dynamic> items,
    required String Function(int i) getName,
    String Function(int i)? getRawName,
    required num Function(int i) getValue,
    required String Function(int i, num value) getTooltipValue,
    required String chartKey,
    required bool privacy,
  }) {
    final indexed = <MapEntry<int, dynamic>>[];
    for (int i = 0; i < items.length; i++) {
      final v = getValue(i);
      if (v > 0) indexed.add(MapEntry(i, items[i]));
    }

    if (indexed.isEmpty) return _buildEmptyPlaceholder(title);

    indexed.sort((a, b) => getValue(b.key).compareTo(getValue(a.key)));
    final total = indexed.fold<num>(0, (sum, e) => sum + getValue(e.key));
    final rawNameFn = getRawName ?? getName;

    final chartData = <_PieData>[];
    for (final entry in indexed) {
      final i = entry.key;
      if (_isHidden(chartKey, i)) continue;
      final v = getValue(i);
      final pct = total > 0 ? (v / total * 100).toStringAsFixed(1) : '0';
      chartData.add(
        _PieData(
          name: getName(i),
          value: v.toDouble(),
          tooltip: '📅 ${rawNameFn(i)}\n${getTooltipValue(i, v)} ($pct%)',
          color: _colors[i % _colors.length],
        ),
      );
    }

    if (chartData.isEmpty) return _buildEmptyPlaceholder(title);
    final visibleTotal = chartData.fold<num>(0, (sum, e) => sum + e.value);
    final totalValue = visibleTotal == visibleTotal.roundToDouble()
        ? visibleTotal.round()
        : visibleTotal;
    final totalLabel = getTooltipValue(0, totalValue);

    return _buildCard(
      title: title,
      child: SizedBox(
        height: _chartHeight,
        child: Row(
          spacing: 4,
          children: [
            Expanded(
              flex: 6,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Listener(
                    onPointerDown: _rememberDashboardTooltipPosition,
                    child: SfCircularChart(
                      margin: EdgeInsets.zero,
                      tooltipBehavior: TooltipBehavior(
                        enable: true,
                        activationMode: ActivationMode.singleTap,
                        tooltipPosition: TooltipPosition.auto,
                        header: '',
                        canShowMarker: false,
                        duration: 10000,
                        builder:
                            (
                              dynamic data,
                              dynamic point,
                              dynamic series,
                              int pointIndex,
                              int seriesIndex,
                            ) => _buildDashboardOverlayTooltip(
                              (data as _PieData).tooltip,
                            ),
                      ),
                      series: <DoughnutSeries<_PieData, String>>[
                        DoughnutSeries<_PieData, String>(
                          dataSource: chartData,
                          xValueMapper: (d, _) => d.name,
                          yValueMapper: (d, _) => d.value,
                          pointColorMapper: (d, _) => d.color,
                          dataLabelSettings: const DataLabelSettings(
                            isVisible: false,
                          ),
                          radius: '88%',
                          innerRadius: '62%',
                          cornerStyle: CornerStyle.bothCurve,
                          explode: false,
                        ),
                      ],
                    ),
                  ),
                  IgnorePointer(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '汇总',
                          style: TextStyle(
                            fontSize: 10,
                            color: FTheme.of(context).colors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 2),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 88),
                          child: Text(
                            totalLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SizedBox(
                  height: _chartHeight,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: indexed.length,
                    itemBuilder: (context, idx) {
                      final i = indexed[idx].key;
                      return _buildLegendItem(
                        getName(i),
                        getTooltipValue(i, getValue(i)),
                        _colors[i % _colors.length],
                        hidden: _isHidden(chartKey, i),
                        onTap: () => _toggleHidden(chartKey, i),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ———————————————— 通用月度柱图 ————————————————

  Widget _buildMonthChart({
    required String title,
    required List<MonthSiteData> data,
    required num Function(StatusRecord record) getValue,
    required String Function(num value) formatValue,
    required String chartKey,
    required bool privacy,
  }) {
    if (data.isEmpty) return _buildEmptyPlaceholder(title);

    final allDates = <String>{};
    for (final site in data) {
      for (final r in site.value) {
        allDates.add(r.createdAt);
      }
    }
    final sortedDates = allDates.toList()..sort();

    if (sortedDates.isEmpty) return _buildEmptyPlaceholder(title);

    final hasAnyData = data.any(
      (site) => site.value.any((r) => getValue(r) > 0),
    );
    if (!hasAnyData) return _buildEmptyPlaceholder(title);

    final tooltipMap = <String, String>{};
    for (final date in sortedDates) {
      num total = 0;
      final siteLines = <String>[];
      for (int j = 0; j < data.length; j++) {
        final records = data[j].value.where((r) => r.createdAt == date);
        final v = records.isNotEmpty ? getValue(records.first) : 0;
        total += v;
        if (v > 0) siteLines.add('${data[j].name}\t${formatValue(v)}');
      }
      tooltipMap[date] =
          '📅 ${_formatMonth(date)}\n汇总\t${formatValue(total)}\n${siteLines.join('\n')}';
    }

    final series = <StackedColumnSeries<_BarData, String>>[];
    for (int i = 0; i < data.length; i++) {
      if (_isHidden(chartKey, i)) continue;
      final site = data[i];
      final seriesData = sortedDates.map((date) {
        final records = site.value.where((r) => r.createdAt == date);
        final v = records.isNotEmpty ? getValue(records.first).toDouble() : 0.0;
        return _BarData(
          label: _formatMonth(date),
          value: v,
          tooltip: tooltipMap[date] ?? '',
        );
      }).toList();
      series.add(
        StackedColumnSeries<_BarData, String>(
          dataSource: seriesData,
          xValueMapper: (d, _) => d.label,
          yValueMapper: (d, _) => d.value,
          name: _mask(site.name, privacy),
          color: _colors[i % _colors.length],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
          width: 0.72,
          spacing: 0.08,
        ),
      );
    }

    return _buildCard(
      title: title,
      child: SizedBox(
        height: _chartHeight,
        child: ClipRect(
          clipBehavior: Clip.none,
          child: Listener(
            onPointerDown: _rememberDashboardTooltipPosition,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              legend: _chartLegend(),
              primaryXAxis: CategoryAxis(
                labelIntersectAction: AxisLabelIntersectAction.wrap,
                maximumLabels: sortedDates.length,
                labelStyle: _chartAxisTextStyle(),
                axisLine: const AxisLine(width: 0),
                majorGridLines: const MajorGridLines(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
              ),
              primaryYAxis: NumericAxis(
                labelStyle: _chartAxisTextStyle(),
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                majorGridLines: MajorGridLines(
                  width: 0.5,
                  color: FTheme.of(
                    context,
                  ).colors.border.withValues(alpha: 0.45),
                ),
                axisLabelFormatter: (AxisLabelRenderDetails details) =>
                    ChartAxisLabel(
                      formatValue(details.value),
                      details.textStyle,
                    ),
              ),
              series: series,
              tooltipBehavior: TooltipBehavior(
                enable: true,
                activationMode: ActivationMode.singleTap,
                tooltipPosition: TooltipPosition.auto,
                header: '',
                canShowMarker: false,
                duration: 10000,
                builder:
                    (
                      dynamic data,
                      dynamic point,
                      dynamic series,
                      int pointIndex,
                      int seriesIndex,
                    ) => _buildDashboardOverlayTooltip(
                      (data as _BarData).tooltip,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ———————————————— Wrapper 方法 ————————————————

  Widget _buildEmailPieChart(List<KV> list, bool privacy) => _buildPieChart(
    title: '邮箱分布',
    items: list,
    chartKey: 'email',
    privacy: privacy,
    getName: (i) => _mask(list[i].name, privacy),
    getRawName: (i) => list[i].name,
    getValue: (i) => list[i].value,
    getTooltipValue: (i, v) => '$v',
  );

  Widget _buildUsernamePieChart(List<KV> list, bool privacy) => _buildPieChart(
    title: '用户名分布',
    items: list,
    chartKey: 'username',
    privacy: privacy,
    getName: (i) => _mask(list[i].name, privacy),
    getRawName: (i) => list[i].name,
    getValue: (i) => list[i].value,
    getTooltipValue: (i, v) => '$v',
  );

  Widget _buildUploadedPieChart(List<SiteStatusData> list, bool privacy) =>
      _buildPieChart(
        title: '站点上传量',
        items: list,
        chartKey: 'uploaded',
        privacy: privacy,
        getName: (i) => _mask(list[i].name, privacy),
        getRawName: (i) => list[i].name,
        getValue: (i) => list[i].value.uploaded,
        getTooltipValue: (i, v) => formatBytes(v),
      );

  Widget _buildTodayUploadPieChart(List<KV> list, bool privacy) =>
      _buildPieChart(
        title: '今日上传增量',
        items: list,
        chartKey: 'todayUpload',
        privacy: privacy,
        getName: (i) => _mask(list[i].name, privacy),
        getRawName: (i) => list[i].name,
        getValue: (i) => list[i].value,
        getTooltipValue: (i, v) => formatBytes(v),
      );

  Widget _buildTodayDownloadPieChart(List<KV> list, bool privacy) =>
      _buildPieChart(
        title: '今日下载增量',
        items: list,
        chartKey: 'todayDownload',
        privacy: privacy,
        getName: (i) => _mask(list[i].name, privacy),
        getRawName: (i) => list[i].name,
        getValue: (i) => list[i].value,
        getTooltipValue: (i, v) => formatBytes(v),
      );

  Widget _buildPublishedCountPieChart(
    List<SiteStatusData> list,
    bool privacy,
  ) => _buildPieChart(
    title: '站点发种数量',
    items: list,
    chartKey: 'publishedCount',
    privacy: privacy,
    getName: (i) => _mask(list[i].name, privacy),
    getRawName: (i) => list[i].name,
    getValue: (i) => list[i].value.published,
    getTooltipValue: (i, v) => '${_formatCount(v)} 个',
  );

  Widget _buildSeedChart(List<KV> list, bool privacy) => _buildPieChart(
    title: '做种分布',
    items: list,
    chartKey: 'seed',
    privacy: privacy,
    getName: (i) => _mask(list[i].name, privacy),
    getRawName: (i) => list[i].name,
    getValue: (i) => list[i].value,
    getTooltipValue: (i, v) => formatBytes(v),
  );

  Widget _buildMonthUploadChart(List<MonthSiteData> list, bool privacy) =>
      _buildMonthChart(
        title: '月度上传增量趋势',
        data: list,
        chartKey: 'monthUpload',
        privacy: privacy,
        getValue: (r) => r.uploaded,
        formatValue: formatYAxis,
      );

  Widget _buildMonthDownloadChart(List<MonthSiteData> list, bool privacy) =>
      _buildMonthChart(
        title: '月度下载增量趋势',
        data: list,
        chartKey: 'monthDownload',
        privacy: privacy,
        getValue: (r) => r.downloaded,
        formatValue: formatYAxis,
      );

  Widget _buildMonthPublishedChart(List<MonthSiteData> list, bool privacy) =>
      _buildMonthChart(
        title: '月度发种增量趋势',
        data: list,
        chartKey: 'monthPublished',
        privacy: privacy,
        getValue: (r) => r.published,
        formatValue: _formatCount,
      );

  // ———————————————— 每日上传柱图 ————————————————

  Widget _buildDailyStackChart(
    String title,
    List<StackSiteData> data,
    bool privacy,
  ) {
    if (data.isEmpty) return _buildEmptyPlaceholder(title);

    const chartKey = 'dailyStack';

    final allDates = <String>{};
    for (final site in data) {
      for (final r in site.value) {
        allDates.add(r.createdAt);
      }
    }
    final sortedDates = allDates.toList()..sort();

    if (sortedDates.isEmpty) return _buildEmptyPlaceholder(title);

    final hasAnyData = data.any(
      (site) => site.value.any((r) => r.uploaded > 0),
    );
    if (!hasAnyData) return _buildEmptyPlaceholder(title);

    final tooltipMap = <String, String>{};
    for (final date in sortedDates) {
      num totalUpload = 0;
      final siteLines = <String>[];
      for (int j = 0; j < data.length; j++) {
        final records = data[j].value.where((r) => r.createdAt == date);
        final u = records.isNotEmpty ? records.first.uploaded : 0;
        totalUpload += u;
        if (u > 0) siteLines.add('${data[j].name}\t${formatBytes(u)}');
      }
      tooltipMap[date] =
          '📅 $date\n汇总\t${formatBytes(totalUpload)}\n${siteLines.join('\n')}';
    }

    final series = <StackedColumnSeries<_BarData, String>>[];
    for (int i = 0; i < data.length; i++) {
      if (_isHidden(chartKey, i)) continue;
      final site = data[i];
      final seriesData = sortedDates.map((date) {
        final records = site.value.where((r) => r.createdAt == date);
        final uploaded = records.isNotEmpty
            ? records.first.uploaded.toDouble()
            : 0.0;
        return _BarData(
          label: _formatDay(date),
          value: uploaded,
          tooltip: tooltipMap[date] ?? '',
        );
      }).toList();
      series.add(
        StackedColumnSeries<_BarData, String>(
          dataSource: seriesData,
          xValueMapper: (d, _) => d.label,
          yValueMapper: (d, _) => d.value,
          name: _mask(site.name, privacy),
          color: _colors[i % _colors.length],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
          width: 0.72,
          spacing: 0.08,
        ),
      );
    }

    return _buildCard(
      title: title,
      child: SizedBox(
        height: _chartHeight,
        child: ClipRect(
          clipBehavior: Clip.none,
          child: Listener(
            onPointerDown: _rememberDashboardTooltipPosition,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              legend: _chartLegend(),
              primaryXAxis: CategoryAxis(
                labelIntersectAction: AxisLabelIntersectAction.wrap,
                maximumLabels: sortedDates.length,
                labelStyle: _chartAxisTextStyle(),
                axisLine: const AxisLine(width: 0),
                majorGridLines: const MajorGridLines(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
              ),
              primaryYAxis: NumericAxis(
                labelStyle: _chartAxisTextStyle(),
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                majorGridLines: MajorGridLines(
                  width: 0.5,
                  color: FTheme.of(
                    context,
                  ).colors.border.withValues(alpha: 0.45),
                ),
                axisLabelFormatter: (AxisLabelRenderDetails details) =>
                    ChartAxisLabel(
                      formatYAxis(details.value),
                      details.textStyle,
                    ),
              ),
              series: series,
              tooltipBehavior: TooltipBehavior(
                enable: true,
                activationMode: ActivationMode.singleTap,
                tooltipPosition: TooltipPosition.auto,
                header: '',
                canShowMarker: false,
                duration: 10000,
                builder:
                    (
                      dynamic data,
                      dynamic point,
                      dynamic series,
                      int pointIndex,
                      int seriesIndex,
                    ) => _buildDashboardOverlayTooltip(
                      (data as _BarData).tooltip,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ———————————————— Treemap ————————————————

  Widget _buildStatusChart(
    String title,
    List<SiteStatusData> data,
    bool privacy,
  ) {
    if (data.isEmpty) return _buildEmptyPlaceholder(title);
    final sorted = data.toList()
      ..sort((a, b) => b.value.uploaded.compareTo(a.value.uploaded));
    final filtered = sorted.where((e) => e.value.uploaded > 0).toList();
    if (filtered.isEmpty) return _buildEmptyPlaceholder(title);
    return _buildCard(
      title: title,
      child: TreemapSection(
        data: filtered,
        privacy: privacy,
        colors: _colors,
        height: _chartHeight,
        // ← 传入动态高度
        displayCount: _treemapCount, // ← 传入
      ),
    );
  }

  // ———————————————— Tooltip ————————————————

  Widget _buildTooltipWidget(String text) {
    final theme = FTheme.of(context);
    final lines = text.split('\n');
    final hasTitle = lines.isNotEmpty && lines.first.startsWith('📅');
    final bodyLines = hasTitle ? lines.skip(1).toList() : lines;

    Widget buildLine(String line) {
      final isSummary = line.startsWith('汇总');
      final tabIndex = line.indexOf('\t');
      if (tabIndex > 0) {
        final name = line.substring(0, tabIndex);
        final value = line.substring(tabIndex + 1);
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 1),
          padding: EdgeInsets.symmetric(
            horizontal: isSummary ? 7 : 0,
            vertical: isSummary ? 5 : 2,
          ),
          decoration: isSummary
              ? BoxDecoration(
                  color: theme.colors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                )
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: theme.typography.sm.copyWith(
                    fontWeight: isSummary ? FontWeight.w800 : FontWeight.w400,
                    color: isSummary
                        ? theme.colors.primary
                        : theme.colors.mutedForeground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                value,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.sm.copyWith(
                  fontWeight: isSummary ? FontWeight.w800 : FontWeight.w500,
                  color: isSummary
                      ? theme.colors.primary
                      : theme.colors.foreground,
                ),
              ),
            ],
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          line,
          style: theme.typography.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 280, maxHeight: 260),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colors.background.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colors.border.withValues(alpha: 0.78)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
            spreadRadius: -4,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      hasTitle ? lines.first : '详情',
                      style: theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colors.foreground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _hideDashboardOverlayTooltip,
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Icon(
                        FIcons.x,
                        size: 14,
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...bodyLines.map(buildLine),
          ],
        ),
      ),
    );
  }

  void _rememberDashboardTooltipPosition(PointerDownEvent event) {
    _dashboardTooltipPosition = event.position;
  }

  Widget _buildDashboardOverlayTooltip(String text) {
    _scheduleDashboardOverlayTooltip(text);
    return const SizedBox.shrink();
  }

  void _scheduleDashboardOverlayTooltip(String text) {
    if (text.trim().isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showDashboardOverlayTooltip(text);
    });
  }

  void _showDashboardOverlayTooltip(String text) {
    final overlay = Overlay.of(context, rootOverlay: true);
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.viewPaddingOf(context);
    const margin = 12.0;
    final tooltipWidth = size.width < 304 ? size.width - margin * 2 : 280.0;
    const tooltipHeight = 260.0;
    final position =
        _dashboardTooltipPosition ?? Offset(size.width / 2, size.height / 2);

    var left = position.dx - tooltipWidth / 2;
    final maxLeft = size.width - tooltipWidth - margin;
    if (left < margin) left = margin;
    if (maxLeft > margin && left > maxLeft) left = maxLeft;

    final minTop = padding.top + margin;
    final maxTop = size.height - padding.bottom - tooltipHeight - margin;
    final aboveTop = position.dy - tooltipHeight - 14;
    final belowTop = position.dy + 14;
    var top = aboveTop >= minTop ? aboveTop : belowTop;
    if (top < minTop) top = minTop;
    if (maxTop > minTop && top > maxTop) top = maxTop;

    _hideDashboardOverlayTooltip();
    _dashboardTooltipEntry = OverlayEntry(
      builder: (_) => Positioned(
        left: left,
        top: top,
        width: tooltipWidth,
        child: Material(
          type: MaterialType.transparency,
          child: _buildTooltipWidget(text),
        ),
      ),
    );
    overlay.insert(_dashboardTooltipEntry!);
    _dashboardTooltipTimer = Timer(
      const Duration(seconds: 12),
      _hideDashboardOverlayTooltip,
    );
  }

  void _hideDashboardOverlayTooltip() {
    _dashboardTooltipTimer?.cancel();
    _dashboardTooltipTimer = null;
    _dashboardTooltipEntry?.remove();
    _dashboardTooltipEntry = null;
  }

  // ———————————————— 图例 ————————————————

  Widget _buildLegendItem(
    String name,
    String? value,
    Color color, {
    required bool hidden,
    required VoidCallback onTap,
  }) {
    final cs = FTheme.of(context).colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        decoration: BoxDecoration(
          color: hidden ? Colors.transparent : color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: hidden
                ? cs.border.withValues(alpha: 0.35)
                : color.withValues(alpha: 0.12),
            width: 0.6,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: hidden ? color.withValues(alpha: 0.3) : color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                name,
                style: FTheme.of(context).typography.xs.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: hidden
                      ? cs.mutedForeground.withValues(alpha: 0.5)
                      : cs.foreground.withValues(alpha: 0.84),
                  decoration: hidden ? TextDecoration.lineThrough : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (value != null)
              Text(
                value,
                style: FTheme.of(context).typography.xs.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: hidden
                      ? cs.mutedForeground.withValues(alpha: 0.5)
                      : cs.mutedForeground,
                ),
              ),
          ],
        ),
      ),
    );
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

class _DesignationCardState extends State<_DesignationCard>
    with TickerProviderStateMixin {
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
    50: [
      Color(0xFF3B82F6),
      Color(0xFF8B5CF6),
      Color(0xFFEC4899),
      Color(0xFF3B82F6),
    ],
    100: [
      Color(0xFFFF6B6B),
      Color(0xFFFF8E53),
      Color(0xFFFFD93D),
      Color(0xFFFF6B6B),
    ],
    150: [
      Color(0xFFE11D48),
      Color(0xFFFF6B6B),
      Color(0xFFFFD93D),
      Color(0xFFE11D48),
    ],
    200: [
      Color(0xFFFFD700),
      Color(0xFFE11D48),
      Color(0xFF9B59B6),
      Color(0xFFFFD700),
    ],
  };

  @override
  void initState() {
    super.initState();
    _popoverCtrl = FPopoverController(vsync: this);
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _popoverCtrl.dispose();
    super.dispose();
  }

  List<Color> get _colors {
    // 找到匹配的等级
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

  Widget _buildPopoverContent(FColors cs, FTypography typo) {
    final entries = _designations.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    final progress = _unlockProgress();
    return Container(
      width: 230,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '称号等级',
            style: typo.sm.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
          ),
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
                      color: isCurrent
                          ? const Color(0xFFE11D48)
                          : (isActive ? const Color(0xFF10B981) : cs.border),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 44,
                    child: Text(
                      '${entry.key}站',
                      style: typo.xs.copyWith(
                        color: isActive
                            ? cs.foreground
                            : cs.mutedForeground.withValues(alpha: 0.4),
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isCurrent) ...[
                          Icon(
                            FIcons.check,
                            size: 13,
                            color: const Color(0xFFE11D48),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            entry.value,
                            textAlign: TextAlign.right,
                            style: typo.xs.copyWith(
                              color: isCurrent
                                  ? const Color(0xFFE11D48)
                                  : (isActive
                                        ? cs.foreground
                                        : cs.mutedForeground.withValues(
                                            alpha: 0.4,
                                          )),
                              fontWeight: isCurrent
                                  ? FontWeight.w700
                                  : FontWeight.normal,
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
    FColors cs,
    FTypography typo,
    _DesignationProgress progress,
  ) {
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
                style: typo.sm.copyWith(
                  color: const Color(0xFFE11D48),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                progress.completed
                    ? '已解锁最高称号'
                    : '距 ${progress.nextTitle} 还差 ${progress.remaining}站',
                style: typo.xs.copyWith(
                  color: cs.mutedForeground,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: cs.border.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(3),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress.ratio.clamp(0.0, 1.0).toDouble(),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE11D48),
                  borderRadius: BorderRadius.circular(3),
                ),
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
            style: typo.xs.copyWith(
              color: cs.foreground,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ———————————————— 数据类 ————————————————

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

class _RatioSegment {
  final double ratio;
  final Color color;

  const _RatioSegment(this.ratio, this.color);
}

class _NamedPair {
  final String name;
  final num primary;
  final num secondary;

  const _NamedPair(this.name, this.primary, this.secondary);
}

class _DistributionGroup {
  final String label;
  final List<KV> items;

  const _DistributionGroup(this.label, this.items);
}

class _DistributionItem {
  final String name;
  final num value;
  final Color color;
  final String? valueText;
  final String? tooltip;

  const _DistributionItem({
    required this.name,
    required this.value,
    required this.color,
    this.valueText,
    this.tooltip,
  });
}

class _IncrementChartItem {
  final String name;
  final num upload;
  final num download;
  final String tooltip;

  const _IncrementChartItem(
    this.name,
    this.upload,
    this.download,
    this.tooltip,
  );
}

class _TrendPoint {
  final String date;
  final num upload;
  final num download;
  final List<MapEntry<String, num>> uploadDetails;
  final List<MapEntry<String, num>> downloadDetails;

  const _TrendPoint(
    this.date,
    this.upload,
    this.download, {
    this.uploadDetails = const [],
    this.downloadDetails = const [],
  });
}

class _ServerResourceUsagePoint {
  final String label;
  final double value;

  const _ServerResourceUsagePoint(this.label, this.value);
}

class _MonthlyChartItem {
  final String label;
  final num value;
  final String displayValue;
  final String tooltip;

  const _MonthlyChartItem(
    this.label,
    this.value,
    this.displayValue,
    this.tooltip,
  );
}

class _PieData {
  final String name;
  final double value;
  final String tooltip;
  final Color color;

  _PieData({
    required this.name,
    required this.value,
    required this.tooltip,
    required this.color,
  });
}

class _BarData {
  final String label;
  final double value;
  final String tooltip;

  _BarData({required this.label, required this.value, required this.tooltip});
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool loading;
  final bool action;

  const _StatItem(
    this.label,
    this.value,
    this.icon,
    this.color, {
    this.onTap,
    this.loading = false,
    this.action = false,
  });
}
