import 'dart:async';

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
import 'widgets/dashboard_cache_clear_popover.dart';
import 'widgets/desktop_chart_config.dart';
import 'widgets/desktop_dashboard_page.dart';
import 'widgets/phone_chart_settings.dart';
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

extension _DashboardThemeRadius on BuildContext {
  shadcn.ThemeData get _dashTheme => shadcn.Theme.of(this);

  BorderRadius get _dashRadiusXs => _dashTheme.borderRadiusXs;

  BorderRadius get _dashRadiusSm => _dashTheme.borderRadiusSm;

  BorderRadius get _dashRadiusMd => _dashTheme.borderRadiusMd;

  BorderRadius get _dashRadiusLg => _dashTheme.borderRadiusLg;

  BorderRadius get _dashRadiusXl => _dashTheme.borderRadiusXl;
}

bool _isDashboardTooltipSummaryLine(String line) {
  final tabIndex = line.indexOf('\t');
  if (tabIndex <= 0) return false;
  final label = line.substring(0, tabIndex).trim();
  return label == '汇总' ||
      label == '今日汇总' ||
      label == '数值' ||
      label == '总数' ||
      label == '总值' ||
      label == '占比';
}

class _DashboardIconTooltip extends StatelessWidget {
  final String message;
  final Widget child;

  const _DashboardIconTooltip({required this.message, required this.child});

  @override
  Widget build(BuildContext context) {
    if (message.trim().isEmpty) return child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showDashboardIconTooltip(context, message),
      child: child,
    );
  }
}

void _showDashboardIconTooltip(BuildContext anchorContext, String message) {
  shadcn.showPopover<void>(
    context: anchorContext,
    handler: const shadcn.PopoverOverlayHandler(),
    alignment: Alignment.topCenter,
    anchorAlignment: Alignment.bottomCenter,
    offset: const Offset(0, 8),
    consumeOutsideTaps: false,
    builder: (context) => _DashboardIconTooltipPanel(message: message),
  );
}

class _DashboardIconTooltipPanel extends StatelessWidget {
  final String message;

  const _DashboardIconTooltipPanel({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final lines = message.split('\n');
    final title = lines.isNotEmpty ? lines.first : '详情';
    final body = lines.length > 1 ? lines.skip(1).toList() : const <String>[];
    final width = (MediaQuery.sizeOf(context).width - 32)
        .clamp(220.0, 320.0)
        .toDouble();

    return shadcn.ModalContainer(
      padding: EdgeInsets.all(theme.density.baseContentPadding * theme.scaling),
      child: SizedBox(
        width: width,
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
              ...body.map((line) {
                final tabIndex = line.indexOf('\t');
                if (tabIndex > 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            line.substring(0, tabIndex),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.typography.xSmall.copyWith(
                              color: cs.mutedForeground,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          line.substring(tabIndex + 1),
                          style: theme.typography.xSmall.copyWith(
                            color: cs.foreground,
                            fontWeight: FontWeight.w700,
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
                    style: theme.typography.xSmall.copyWith(
                      color: cs.mutedForeground,
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
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

  List<Color> get _colors {
    final cs = shadcn.Theme.of(context).colorScheme;
    return [
      cs.primary,
      _dashboardThemeTone(cs.primary, hueShift: 42, lightnessDelta: 0.04),
      _dashboardThemeTone(cs.primary, hueShift: -34, saturationScale: 0.88),
      cs.destructive,
      _dashboardThemeTone(cs.primary, hueShift: 86, saturationScale: 0.82),
      _dashboardThemeTone(cs.destructive, hueShift: 24, lightnessDelta: 0.04),
      _dashboardThemeBlend(cs.primary, cs.destructive, 0.4),
      _dashboardThemeTone(
        cs.secondary,
        saturationScale: 1.35,
        lightnessDelta: -0.08,
      ),
      _dashboardThemeTone(cs.primary, hueShift: 126, saturationScale: 0.76),
      _dashboardThemeTone(cs.destructive, hueShift: -38, saturationScale: 0.88),
      _dashboardThemeTone(cs.primary, hueShift: -82, saturationScale: 0.78),
      _dashboardThemeTone(cs.mutedForeground, saturationScale: 1.2),
    ];
  }

  Color _dashboardThemeTone(
    Color color, {
    double hueShift = 0,
    double saturationScale = 1,
    double lightnessDelta = 0,
  }) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withHue((hsl.hue + hueShift) % 360)
        .withSaturation((hsl.saturation * saturationScale).clamp(0.18, 0.9))
        .withLightness((hsl.lightness + lightnessDelta).clamp(0.26, 0.74))
        .toColor();
  }

  Color _dashboardThemeBlend(Color a, Color b, double t) {
    return Color.lerp(a, b, t) ?? a;
  }

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
  int _phoneTrendDays = DashboardChartConfig.defaultPhoneTrendDays;
  bool _isRefreshingDashboardData = false;
  bool _isRefreshingSiteData = false;
  bool _isSigningInSites = false;

  bool get _hasRunningSummaryAction =>
      _isRefreshingDashboardData || _isRefreshingSiteData || _isSigningInSites;

  @override
  void initState() {
    super.initState();
    _refreshController = EasyRefreshController(controlFinishRefresh: true);
    _chartOrder = DashboardChartConfig.getOrder();
    _chartVisibility = DashboardChartConfig.getVisibility();
    _chartHeight = DashboardChartConfig.getChartHeight(); // ← 新增
    _treemapCount = DashboardChartConfig.getTreemapCount();
    _phoneTrendDays = DashboardChartConfig.getPhoneTrendDays();
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

  void _showChartSettings(
    BuildContext anchorContext, {
    bool allowReorder = true,
  }) {
    shadcn.showDialog<void>(
      context: context,
      builder: (ctx) => ChartSettingsDialog(
        order: _chartOrder,
        visibility: _chartVisibility,
        chartHeight: _chartHeight,
        treemapCount: _treemapCount,
        allowReorder: allowReorder,
        showSizingControls: allowReorder,
        onSaved: (order, visibility, height, treemapCount, phoneTrendDays) {
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
            _phoneTrendDays = phoneTrendDays;
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
    try {
      await ref
          .read(appAutoRefreshControllerProvider)
          .refresh(dashboardDays: _phoneDashboardFetchDays);
    } finally {
      _refreshController.finishRefresh();
    }
  }

  Future<void> _refreshDashboardData() async {
    if (_hasRunningSummaryAction) return;
    setState(() => _isRefreshingDashboardData = true);

    try {
      await ref
          .read(appAutoRefreshControllerProvider)
          .refresh(dashboardDays: _phoneDashboardFetchDays);
      Toast.success('刷新数据完成');
    } catch (e, st) {
      AppLogger.error('刷新首页数据失败', e, st);
      Toast.error('刷新数据失败');
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

  @override
  Widget build(BuildContext context) {
    if (!context.isMobile) return const DesktopDashboardPage();

    final data = ref.watch(dashboardNotifierProvider);
    final cacheInfo = ref.watch(dashboardCacheInfoProvider);
    final refreshSerial = ref.watch(dashboardRefreshSerialProvider);
    final privacy = ref.watch(privacyModeProvider);
    final isPhone = PlatformTool.isPhone();
    final cs = shadcn.Theme.of(context).colorScheme;
    final pageBackground = appSurfaceColor(context, cs.background);

    if (data == null) {
      return AppBackground(
        child: shadcn.Scaffold(
          backgroundColor: pageBackground,
          child: Center(child: shadcn.CircularProgressIndicator(size: 18)),
        ),
      );
    }

    return Stack(
      children: [
        isPhone
            ? _buildPhoneLayout(data, privacy, cacheInfo, refreshSerial)
            : _buildDesktopLayout(data, privacy, cacheInfo, refreshSerial),
        // 浮动工具
        Positioned(
          right: 12,
          bottom: _bottomSafeGap + ShellBottomSpacing.value(context),
          child: Column(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            children: [
              shadcn.IconButton.ghost(
                icon: Icon(
                  privacy ? shadcn.LucideIcons.eyeOff : shadcn.LucideIcons.eye,
                ),
                onPressed: () =>
                    ref.read(privacyModeProvider.notifier).toggle(),
              ),
              Builder(
                builder: (buttonContext) => shadcn.IconButton.ghost(
                  icon: const Icon(shadcn.LucideIcons.trash2),
                  onPressed: () => showDashboardCacheClearPopover(
                    buttonContext,
                    above: true,
                  ),
                ),
              ),
              Builder(
                builder: (buttonContext) => shadcn.IconButton.ghost(
                  icon: const Icon(shadcn.LucideIcons.slidersHorizontal),
                  onPressed: () => _showChartSettings(buttonContext),
                ),
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
        borderRadius: context._dashRadiusXl,
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
    final cs = shadcn.Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.muted.withValues(alpha: 0.28),
        borderRadius: context._dashRadiusLg,
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
                  borderRadius: context._dashRadiusMd,
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
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
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
          ? cs.primary
          : _dashboardThemeTone(cs.primary, hueShift: 42, lightnessDelta: 0.04),
      loading: () => _dashboardThemeTone(cs.primary, hueShift: -36),
      error: (_, __) => cs.destructive,
    );
    return AppSurfaceContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      borderRadius: context._dashRadiusXl,
      color: appSurfaceColor(context, cs.card),
      borderColor: cs.border.withValues(alpha: 0.34),
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
                  borderRadius: context._dashRadiusLg,
                  border: Border.all(color: cs.primary.withValues(alpha: 0.16)),
                ),
                child: Icon(
                  shadcn.LucideIcons.user,
                  size: 24,
                  color: cs.primary,
                ),
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
                            color: _dashboardThemeTone(
                              cs.primary,
                              hueShift: 42,
                              lightnessDelta: 0.04,
                            ),
                            icon: shadcn.LucideIcons.circleAlert,
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
              shadcn.IconButton.ghost(
                onPressed: () async =>
                    ref.read(authNotifierProvider.notifier).logout(),
                icon: Icon(
                  shadcn.LucideIcons.logOut,
                  size: 16,
                  color: cs.destructive,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildServerMetricTile(
                  icon: shadcn.LucideIcons.user,
                  label: '登录用户',
                  title: username,
                  subtitle: userSubtitle,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildServerMetricTile(
                  icon: shadcn.LucideIcons.shieldCheck,
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

  // ———————————————— 卡片容器 ————————————————

  Widget _buildCard({
    required String title,
    required Widget child,
    Widget? legend,
  }) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;

    return AppSurfaceContainer(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      borderRadius: context._dashRadiusMd,
      color: appSurfaceColor(context, cs.background),
      borderColor: cs.border.withValues(alpha: 0.72),
      borderWidth: 0.8,
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
                  borderRadius: context._dashRadiusSm,
                ),
                child: Icon(
                  shadcn.LucideIcons.chartNoAxesCombined,
                  size: 12,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: shadcn.Theme.of(
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
                shadcn.LucideIcons.chartNoAxesCombined,
                size: 32,
                color: shadcn.Theme.of(
                  context,
                ).colorScheme.mutedForeground.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 8),
              Text(
                '暂无数据',
                style: shadcn.Theme.of(context).typography.small.copyWith(
                  color: shadcn.Theme.of(
                    context,
                  ).colorScheme.mutedForeground.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ———————————————— Treemap ————————————————

  Widget _buildStatusChart(
    String title,
    List<SiteStatusData> data,
    bool privacy, {
    List<Color>? colors,
  }) {
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
        colors: colors ?? _colors,
        height: _chartHeight,
        // ← 传入动态高度
        displayCount: _treemapCount, // ← 传入
      ),
    );
  }

  // ———————————————— Tooltip ————————————————

  Widget _buildTooltipWidget(String text) {
    return _DashboardPagedTooltip(
      text: text,
      onClose: _hideDashboardOverlayTooltip,
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
    final availableWidth = (size.width - margin * 2)
        .clamp(160.0, size.width)
        .toDouble();
    final availableHeight =
        (size.height - padding.top - padding.bottom - margin * 2)
            .clamp(160.0, size.height)
            .toDouble();
    final tooltipWidth = availableWidth.clamp(160.0, 420.0).toDouble();
    final tooltipHeight = _dashboardTooltipPreferredHeight(
      text,
      availableHeight,
    );
    final position =
        _dashboardTooltipPosition ?? Offset(size.width / 2, size.height / 2);

    final minTop = padding.top + margin;
    final maxTop = (size.height - padding.bottom - tooltipHeight - margin)
        .clamp(minTop, size.height)
        .toDouble();
    final aboveTop = position.dy - tooltipHeight - 14;
    final belowTop = position.dy + 14;
    var top = aboveTop >= minTop ? aboveTop : belowTop;
    top = top.clamp(minTop, maxTop).toDouble();

    final minLeft = margin;
    final maxLeft = (size.width - tooltipWidth - margin)
        .clamp(minLeft, size.width)
        .toDouble();
    var left = position.dx - tooltipWidth / 2;
    left = left.clamp(minLeft, maxLeft).toDouble();

    _hideDashboardOverlayTooltip();
    _dashboardTooltipEntry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _hideDashboardOverlayTooltip,
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
                  child: _buildTooltipWidget(text),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    overlay.insert(_dashboardTooltipEntry!);
    _dashboardTooltipTimer = Timer(
      const Duration(seconds: 12),
      _hideDashboardOverlayTooltip,
    );
  }

  double _dashboardTooltipPreferredHeight(String text, double availableHeight) {
    final lines = text.split('\n');
    final hideTitle = lines.isNotEmpty && lines.first == '__NO_HEADER__';
    final hasDateTitle = lines.isNotEmpty && lines.first.startsWith('📅');
    final hasPlainTitle =
        lines.isNotEmpty &&
        !hideTitle &&
        !hasDateTitle &&
        !lines.first.contains('\t');
    final bodyLines =
        (hideTitle || hasDateTitle || hasPlainTitle ? lines.skip(1) : lines)
            .where((line) => line.trim().isNotEmpty)
            .toList();
    final summaryCount = bodyLines.where(_isDashboardTooltipSummaryLine).length;
    final detailCount = bodyLines.length - summaryCount;
    if (detailCount <= 0) {
      return 58.0.clamp(52.0, availableHeight.clamp(52.0, 380.0)).toDouble();
    }
    final visibleDetails = detailCount.clamp(1, 8).toInt();
    final pagerHeight = detailCount > 8 ? 40.0 : 0.0;
    final preferred = 64.0 + visibleDetails * 32.0 + pagerHeight;
    return preferred
        .clamp(112.0, availableHeight.clamp(112.0, 380.0))
        .toDouble();
  }

  void _hideDashboardOverlayTooltip() {
    _dashboardTooltipTimer?.cancel();
    _dashboardTooltipTimer = null;
    _dashboardTooltipEntry?.remove();
    _dashboardTooltipEntry = null;
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

  List<Color> get _colors {
    // 找到匹配的等级
    for (final key in _gradients.keys.toList().reversed) {
      if (widget.siteCount >= key) return _gradients[key]!;
    }
    return _gradients[1]!;
  }

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final typo = shadcn.Theme.of(context).typography;

    return GestureDetector(
      onTap: () => shadcn.showPopover(
        context: context,
        handler: shadcn.PopoverOverlayHandler(),
        // Position the popover above the button, shifted by 8px.
        alignment: Alignment.topCenter,
        offset: const Offset(0, 8),
        builder: (BuildContext context) =>
            _buildPopoverContent(cs, typo).sized(width: 300),
      ),
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

  Widget _buildPopoverContent(shadcn.ColorScheme cs, shadcn.Typography typo) {
    final entries = _designations.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    final progress = _unlockProgress();
    return AppSurfaceContainer(
      width: 230,
      padding: const EdgeInsets.all(12),
      borderRadius: context._dashRadiusMd,
      color: appSurfaceColor(context, cs.card),
      borderColor: cs.border,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '称号等级',
            style: typo.small.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
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
                      style: typo.xSmall.copyWith(
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
                            shadcn.RadixIcons.check,
                            size: 13,
                            color: const Color(0xFFE11D48),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            entry.value,
                            textAlign: TextAlign.right,
                            style: typo.xSmall.copyWith(
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
    shadcn.ColorScheme cs,
    shadcn.Typography typo,
    _DesignationProgress progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.muted.withValues(alpha: 0.18),
        borderRadius: context._dashRadiusMd,
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
                style: typo.xSmall.copyWith(
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
              borderRadius: context._dashRadiusXs,
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress.ratio.clamp(0.0, 1.0).toDouble(),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE11D48),
                  borderRadius: context._dashRadiusXs,
                ),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            progress.completed
                ? '当前称号：${progress.currentTitle}'
                : '${progress.currentLevel}站 ${progress.currentTitle} -> ${progress.nextLevel}站 ${progress.nextTitle}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typo.xSmall.copyWith(
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

class _DashboardPagedTooltip extends StatefulWidget {
  final String text;
  final VoidCallback onClose;

  const _DashboardPagedTooltip({required this.text, required this.onClose});

  @override
  State<_DashboardPagedTooltip> createState() => _DashboardPagedTooltipState();
}

class _DashboardPagedTooltipState extends State<_DashboardPagedTooltip> {
  static const _linesPerPage = 8;

  late final PageController _pageController;
  late final String _title;
  late final List<String> _summaryLines;
  late final List<String> _detailLines;
  late final List<List<String>> _pages;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    final rawLines = widget.text.split('\n');
    final hideTitle = rawLines.isNotEmpty && rawLines.first == '__NO_HEADER__';
    final hasDateTitle = rawLines.isNotEmpty && rawLines.first.startsWith('📅');
    final hasPlainTitle =
        rawLines.isNotEmpty &&
        !hideTitle &&
        !hasDateTitle &&
        !rawLines.first.contains('\t');
    _title = hideTitle
        ? '详情'
        : (hasDateTitle || hasPlainTitle)
        ? rawLines.first
        : '详情';
    final bodyLines =
        (hideTitle || hasDateTitle || hasPlainTitle
                ? rawLines.skip(1)
                : rawLines)
            .where((line) => line.trim().isNotEmpty)
            .toList();
    _summaryLines = bodyLines.where(_isDashboardTooltipSummaryLine).toList();
    _detailLines = bodyLines
        .where((line) => !_isDashboardTooltipSummaryLine(line))
        .toList();
    _pages = _chunkLines(_detailLines);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<List<String>> _chunkLines(List<String> lines) {
    final pages = <List<String>>[];
    for (var i = 0; i < lines.length; i += _linesPerPage) {
      final end = (i + _linesPerPage).clamp(0, lines.length).toInt();
      pages.add(lines.sublist(i, end));
    }
    return pages;
  }

  void _goToPage(int page) {
    if (page < 0 || page >= _pages.length) return;
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildLine(BuildContext context, String line) {
    final theme = shadcn.Theme.of(context);
    final tabIndex = line.indexOf('\t');
    if (tabIndex > 0) {
      final name = line.substring(0, tabIndex);
      final value = line.substring(tabIndex + 1);
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                name,
                style: theme.typography.small.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.mutedForeground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.small.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.foreground,
              ),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        line,
        style: theme.typography.small.copyWith(
          color: theme.colorScheme.mutedForeground,
        ),
      ),
    );
  }

  Widget _buildSummaryChip(BuildContext context, String line) {
    final theme = shadcn.Theme.of(context);
    final tabIndex = line.indexOf('\t');
    final label = tabIndex > 0 ? line.substring(0, tabIndex) : line;
    final value = tabIndex > 0 ? line.substring(tabIndex + 1) : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: context._dashRadiusSm,
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
          width: 0.6,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.typography.xSmall.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final hasDetails = _pages.isNotEmpty;
    final hasPager = _pages.length > 1;
    final canPrev = _page > 0;
    final canNext = _page < _pages.length - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.background.withValues(alpha: 0.98),
        borderRadius: context._dashRadiusMd,
        border: Border.all(
          color: theme.colorScheme.border.withValues(alpha: 0.78),
        ),
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
                  child: Icon(
                    shadcn.LucideIcons.x,
                    size: 15,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
          if (hasDetails) ...[
            Divider(
              height: 18,
              color: theme.colorScheme.border.withValues(alpha: 0.45),
            ),
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
                      children: _pages[index]
                          .map((line) => _buildLine(context, line))
                          .toList(),
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
                      color: canPrev
                          ? theme.colorScheme.foreground
                          : theme.colorScheme.mutedForeground,
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
                      color: canNext
                          ? theme.colorScheme.foreground
                          : theme.colorScheme.mutedForeground,
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

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatItem(this.label, this.value, this.icon, this.color, {this.onTap});
}
