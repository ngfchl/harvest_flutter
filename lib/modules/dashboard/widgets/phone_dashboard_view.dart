part of '../dashboard_page.dart';

extension _PhoneDashboardView on _DashboardPageState {
  List<Color> get _phoneTreemapChartColors {
    final cs = shadcn.Theme.of(context).colorScheme;
    return [
      cs.primary,
      cs.destructive,
      _phoneChartTone(cs.primary, hueShift: 28, lightnessDelta: 0.03),
      _phoneChartTone(cs.primary, hueShift: -24, saturationScale: 0.92),
      _phoneChartTone(cs.destructive, hueShift: 24, lightnessDelta: 0.04),
      _phoneChartTone(cs.primary, hueShift: 64, saturationScale: 0.9),
      _phoneChartBlend(cs.primary, cs.destructive, 0.45),
      _phoneChartTone(cs.secondary, saturationScale: 1.4, lightnessDelta: -0.08),
      _phoneChartTone(cs.primary, hueShift: 120, saturationScale: 0.82),
      _phoneChartTone(cs.destructive, hueShift: -34, saturationScale: 0.9),
      _phoneChartTone(cs.primary, hueShift: -76, saturationScale: 0.82),
      _phoneChartTone(cs.mutedForeground, saturationScale: 1.25),
    ];
  }

  Color _phoneChartTone(Color color, {double hueShift = 0, double saturationScale = 1, double lightnessDelta = 0}) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withHue((hsl.hue + hueShift) % 360)
        .withSaturation((hsl.saturation * saturationScale).clamp(0.18, 0.88))
        .withLightness((hsl.lightness + lightnessDelta).clamp(0.28, 0.72))
        .toColor();
  }

  Color _phoneChartBlend(Color a, Color b, double t) {
    return Color.lerp(a, b, t) ?? a;
  }

  Color _phoneTreemapChartColor(int index, {double alpha = 1}) {
    final colors = _phoneTreemapChartColors;
    return colors[index % colors.length].withValues(alpha: alpha);
  }

  Color get _phoneUploadChartColor => _phoneTreemapChartColor(0);

  Color get _phoneDownloadChartColor => _phoneTreemapChartColor(1);

  Color get _phonePublishChartColor => _phoneTreemapChartColor(2);

  Color get _phoneCpuChartColor => _phoneTreemapChartColor(3);

  Color get _phoneMemoryChartColor => _phoneTreemapChartColor(4);

  Color get _phoneSuccessColor => shadcn.Theme.of(context).colorScheme.primary;

  Color get _phoneWarningColor => _phonePublishChartColor;

  Color get _phoneErrorColor => shadcn.Theme.of(context).colorScheme.destructive;

  double get _phoneChartAnimationDuration => ref.watch(screenshotModeProvider) ? 0 : 1500;

  List<String> _phoneVisibleDateKeys(DashboardData data) {
    final dates = <String>{};
    for (final site in data.uploadMonthIncrementDataList) {
      for (final record in site.value) {
        if (record.createdAt.trim().isNotEmpty) {
          dates.add(record.createdAt.trim());
        }
      }
    }
    final sorted = dates.toList()..sort();
    if (sorted.length <= _phoneTrendDays) return sorted;
    return sorted.sublist(sorted.length - _phoneTrendDays);
  }

  List<String> _phoneTrendDateKeys(DashboardData data) {
    final dates = <String>{};
    for (final site in data.stackChartDataList) {
      for (final record in site.value) {
        if (record.createdAt.trim().isNotEmpty) {
          dates.add(record.createdAt.trim());
        }
      }
    }
    final sorted = dates.toList()..sort();
    if (sorted.length <= _phoneTrendDays) return sorted;
    return sorted.sublist(sorted.length - _phoneTrendDays);
  }

  List<_TrendPoint> _buildPhoneTrendPoints(DashboardData data, bool privacy) {
    final dates = _phoneTrendDateKeys(data);
    if (dates.isEmpty) return const [];

    final totals = {for (final date in dates) date: _TrendPoint(date, 0, 0)};
    final uploadDetails = {for (final date in dates) date: <MapEntry<String, num>>[]};
    final downloadDetails = {for (final date in dates) date: <MapEntry<String, num>>[]};

    for (final site in data.stackChartDataList) {
      for (final record in site.value) {
        final date = record.createdAt.trim();
        final current = totals[date];
        if (current == null) continue;
        totals[date] = _TrendPoint(date, current.upload + record.uploaded, current.download + record.downloaded);
        if (record.uploaded > 0) {
          uploadDetails[date]?.add(MapEntry(_mask(site.name, privacy), record.uploaded));
        }
        if (record.downloaded > 0) {
          downloadDetails[date]?.add(MapEntry(_mask(site.name, privacy), record.downloaded));
        }
      }
    }

    return dates.map((date) {
      final point = totals[date]!;
      final uploads = [...uploadDetails[date] ?? const <MapEntry<String, num>>[]]
        ..sort((a, b) => b.value.compareTo(a.value));
      final downloads = [...downloadDetails[date] ?? const <MapEntry<String, num>>[]]
        ..sort((a, b) => b.value.compareTo(a.value));
      return _TrendPoint(date, point.upload, point.download, uploadDetails: uploads, downloadDetails: downloads);
    }).toList();
  }

  TextStyle _phoneTitleStyle(double fontSize) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    return theme.typography.large.copyWith(fontSize: fontSize, fontWeight: FontWeight.w900, color: cs.foreground);
  }

  TextStyle _phonePrimaryTextStyle({required double fontSize, required FontWeight fontWeight, double? height}) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    return theme.typography.small.copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: cs.foreground,
      height: height,
    );
  }

  // ———————————————— 手机布局 ————————————————

  Widget _buildPhoneLayout(DashboardData data, bool privacy, DataCacheInfo cacheInfo, int refreshSerial) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final children = <Widget>[
      CacheStatusBanner(
        info: cacheInfo,
        margin: EdgeInsets.only(top: theme.density.baseGap * theme.scaling),
      ),
      ..._buildPolishedPhoneDashboardChildren(data, privacy),
      SizedBox(height: _DashboardPageState._bottomSafeGap + ShellBottomSpacing.value(context)),
    ];

    final scrollView = SizedBox.expand(
      child: ColoredBox(
        color: cs.background,
        child: EasyRefresh(
          key: ValueKey('phone-dashboard-$refreshSerial'),
          controller: _refreshController,
          onRefresh: _onRefresh,
          header: appRefreshHeader(context),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.density.baseContentPadding * theme.scaling,
                  vertical: theme.density.baseGap * theme.scaling * 2.25,
                ),
                sliver: SliverList(delegate: SliverChildListDelegate(children)),
              ),
            ],
          ),
        ),
      ),
    );

    return shadcn.Scaffold(backgroundColor: cs.background, child: scrollView);
  }

  List<Widget> _buildPolishedPhoneDashboardChildren(DashboardData data, bool privacy) {
    final theme = shadcn.Theme.of(context);
    final children = <Widget>[];

    for (final id in _chartOrder) {
      if (!(_chartVisibility[id] ?? true)) continue;
      final child = _buildPhoneDashboardModule(id, data, privacy);
      if (child == null) continue;
      children
        ..add(SizedBox(height: theme.density.baseGap * theme.scaling * 1.5))
        ..add(child);
    }

    return children;
  }

  Widget? _buildPhoneDashboardModule(String id, DashboardData data, bool privacy) {
    switch (id) {
      case 'phoneServer':
        return _buildServerBar(privacy);
      case 'phoneServerResource':
        return _buildServerResourceCard(privacy);
      case 'phoneServiceStatus':
        return _buildBackendServiceStatusCard();
      case 'phoneDesignation':
        return _buildPhoneDesignationPanel(data);
      case 'phoneOverview':
        return _buildPhoneOverviewCard(data);
      case 'phoneActions':
        return _buildPhoneQuickActionsCard();
      case 'phoneTrend':
        return _buildPhoneTrendCard(data, privacy);
      case 'phoneStatus':
        return _buildStatusChart('站点状态', data.statusList, privacy, colors: _phoneTreemapChartColors);
      case 'phoneUploadShare':
        return _buildPhoneUploadDistributionCard(data, privacy);
      case 'phoneAccount':
        return _buildPhoneUserDistributionCard(data, privacy);
      case 'phoneToday':
        return _buildPhoneTodayIncrementCard(data, privacy);
      case 'phoneSeedShare':
        return _buildPhoneSeedDistributionCard(data, privacy);
      case 'phoneMonthUpload':
        return _buildPhoneMonthlyMetricCard(
          title: '月度上传',
          data: data.uploadMonthIncrementDataList,
          getValue: (record) => record.uploaded,
          formatValue: formatBytes,
          color: _phoneUploadChartColor,
          privacy: privacy,
        );
      case 'phoneMonthDownload':
        return _buildPhoneMonthlyMetricCard(
          title: '月度下载',
          data: data.uploadMonthIncrementDataList,
          getValue: (record) => record.downloaded,
          formatValue: formatBytes,
          color: _phoneDownloadChartColor,
          privacy: privacy,
        );
      case 'phoneMonthPublish':
        return _buildPhoneMonthlyMetricCard(
          title: '月度发种',
          data: data.uploadMonthIncrementDataList,
          getValue: (record) => record.published,
          formatValue: (value) => '${_formatCount(value)} 个',
          color: _phonePublishChartColor,
          privacy: privacy,
        );
      default:
        return null;
    }
  }

  Widget _buildPhoneDesignationPanel(DashboardData data) {
    final cs = shadcn.Theme.of(context).colorScheme;
    const red = Color(0xFFE11D48);
    final siteCount = data.siteCount.toInt();
    final designation = _getDesignation(data.siteCount);
    final progress = _phoneDesignationProgress(siteCount);
    final subtitle = progress.completed
        ? '$siteCount 个站点接入 · 最高等级'
        : '$siteCount 个站点接入 · 下级 ${progress.nextTitle} 还差 ${progress.remaining} 站';

    return _buildBeautyCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 22,
                child: Center(
                  child: Text(
                    '称号',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    strutStyle: const StrutStyle(forceStrutHeight: true, height: 1.0),
                    style: _phonePrimaryTextStyle(
                      fontSize: shadcn.Theme.of(context).typography.large.fontSize ?? 17,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      subtitle,
                      maxLines: 1,
                      softWrap: false,
                      textAlign: TextAlign.right,
                      style: shadcn.Theme.of(context).typography.xSmall.copyWith(
                        color: cs.mutedForeground,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                SizedBox(
                  width: 54,
                  height: 54,
                  child: shadcn.Card(
                    padding: EdgeInsets.zero,
                    filled: true,
                    fillColor: red.withValues(alpha: 0.12),
                    borderColor: red.withValues(alpha: 0.28),
                    child: Icon(shadcn.LucideIcons.award, size: 30, color: red),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: _DesignationCard(
                    designation: designation,
                    siteCount: siteCount,
                    width: 190,
                    height: 48,
                    fontSize: 28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerResourceCard(bool privacy) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final state = ref.watch(serverResourceProvider);
    final interval = ref.watch(serverResourceIntervalProvider);
    final remaining = ref.watch(serverResourceRemainingProvider);
    final data = state.data;
    final running = state.running;
    final statusText = state.error != null
        ? '连接失败'
        : running
        ? '监控中'
        : '已停止';
    final statusColor = state.error != null
        ? _phoneErrorColor
        : running
        ? _phoneSuccessColor
        : cs.mutedForeground;
    final remainingText = '${remaining ~/ 60}:${(remaining % 60).toString().padLeft(2, '0')}';
    final latestText = data?.timestamp == null ? null : '更新于 ${_formatDashboardTimeToSecond(data!.timestamp!)}';
    final serverHost = _serverHostLabel(AppConfig.baseUrl, privacy);

    return _buildBeautyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('服务器状态', style: _phoneTitleStyle(17))),
              if (running) ...[
                Flexible(
                  child: Text(
                    '间隔 ${interval}s · 运行 $remainingText',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: shadcn.Theme.of(
                      context,
                    ).typography.xSmall.copyWith(color: cs.mutedForeground, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              shadcn.Card(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                filled: true,
                fillColor: statusColor.withValues(alpha: 0.12),
                borderColor: statusColor.withValues(alpha: 0.16),
                child: Text(
                  statusText,
                  style: shadcn.Theme.of(
                    context,
                  ).typography.xSmall.copyWith(color: statusColor, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 8),
              shadcn.IconButton.ghost(
                onPressed: () => ref.read(serverResourceProvider.notifier).toggle(),
                icon: Icon(running ? shadcn.LucideIcons.pause : shadcn.LucideIcons.play, size: 17),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  serverHost,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: shadcn.Theme.of(
                    context,
                  ).typography.small.copyWith(color: cs.foreground, fontWeight: FontWeight.w800),
                ),
              ),
              if (latestText != null) ...[
                const SizedBox(width: 10),
                Text(
                  latestText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: shadcn.Theme.of(
                    context,
                  ).typography.xSmall.copyWith(color: cs.mutedForeground, fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildServerResourceMetric(
                  icon: shadcn.LucideIcons.cpu,
                  label: 'CPU',
                  value: '${(data?.cpu.percent ?? 0).toStringAsFixed(1)}%',
                  subtitle: '${(data?.cpu.limitCores ?? 0).toStringAsFixed(1)} 核',
                  color: _phoneCpuChartColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildServerResourceMetric(
                  icon: shadcn.LucideIcons.memoryStick,
                  label: '内存',
                  value: '${(data?.memory.percent ?? 0).toStringAsFixed(1)}%',
                  subtitle: '${formatBytes(data?.memory.workingSet ?? 0)} / ${formatBytes(data?.memory.limit ?? 0)}',
                  color: _phoneMemoryChartColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildServerResourceMetric(
                  icon: shadcn.LucideIcons.arrowUp,
                  label: '上传',
                  value: formatSpeed(data?.network.uploadSpeed ?? 0),
                  subtitle: formatBytes(data?.network.bytesSent ?? 0),
                  color: _phoneUploadChartColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildServerResourceMetric(
                  icon: shadcn.LucideIcons.arrowDown,
                  label: '下载',
                  value: formatSpeed(data?.network.downloadSpeed ?? 0),
                  subtitle: formatBytes(data?.network.bytesRecv ?? 0),
                  color: _phoneDownloadChartColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildServerResourceUsageChart(
            title: 'CPU 占用',
            value: data?.cpu.percent ?? 0,
            history: state.history,
            valueOf: (item) => item.cpu.percent,
            color: _phoneCpuChartColor,
          ),
          const SizedBox(height: 10),
          _buildServerResourceUsageChart(
            title: '内存占用',
            value: data?.memory.percent ?? 0,
            history: state.history,
            valueOf: (item) => item.memory.percent,
            color: _phoneMemoryChartColor,
          ),
        ],
      ),
    );
  }

  Widget _buildServerResourceUsageChart({
    required String title,
    required double value,
    required List<ServerResourceStatus> history,
    required double Function(ServerResourceStatus item) valueOf,
    required Color color,
  }) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final points = _serverResourceUsagePoints(history, valueOf);

    return SizedBox(
      height: 132,
      child: shadcn.Card(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
        filled: true,
        fillColor: color.withValues(alpha: 0.055),
        borderColor: color.withValues(alpha: 0.12),
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
                    style: shadcn.Theme.of(
                      context,
                    ).typography.xSmall.copyWith(color: cs.foreground, fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  '${value.toStringAsFixed(1)}%',
                  style: shadcn.Theme.of(context).typography.small.copyWith(color: color, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Expanded(
              child: points.isEmpty
                  ? Center(
                      child: Text(
                        '等待数据',
                        style: shadcn.Theme.of(
                          context,
                        ).typography.xSmall.copyWith(color: cs.mutedForeground, fontWeight: FontWeight.w600),
                      ),
                    )
                  : SfCartesianChart(
                      plotAreaBorderWidth: 0,
                      margin: EdgeInsets.zero,
                      primaryXAxis: CategoryAxis(isVisible: false, majorGridLines: const MajorGridLines(width: 0)),
                      primaryYAxis: NumericAxis(
                        minimum: 0,
                        maximum: 100,
                        interval: 50,
                        axisLine: const AxisLine(width: 0),
                        majorTickLines: const MajorTickLines(size: 0),
                        majorGridLines: MajorGridLines(width: 0.5, color: cs.border.withValues(alpha: 0.42)),
                        labelStyle: shadcn.Theme.of(context).typography.xSmall.copyWith(
                          color: cs.mutedForeground,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                        axisLabelFormatter: (details) => ChartAxisLabel('${details.value.toInt()}%', details.textStyle),
                      ),
                      series: <CartesianSeries>[
                        SplineAreaSeries<_ServerResourceUsagePoint, String>(
                          animationDuration: _phoneChartAnimationDuration,
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
      return _ServerResourceUsagePoint(label, valueOf(entry.value).clamp(0, 100).toDouble());
    }).toList();
  }

  Widget _buildServerResourceMetric({
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return shadcn.Card(
      padding: const EdgeInsets.all(12),
      filled: true,
      fillColor: color.withValues(alpha: 0.055),
      borderColor: color.withValues(alpha: 0.10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: shadcn.Theme.of(
                    context,
                  ).typography.xSmall.copyWith(color: cs.mutedForeground, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: shadcn.Theme.of(
              context,
            ).typography.large.copyWith(color: color, fontWeight: FontWeight.w900, height: 1.1),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: shadcn.Theme.of(
              context,
            ).typography.xSmall.copyWith(color: cs.mutedForeground, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildBackendServiceStatusCard() {
    final cs = shadcn.Theme.of(context).colorScheme;
    final state = ref.watch(backendServiceStatusProvider);
    final data = state.data;
    final summary = data?.summary ?? BackendServiceSummary.empty;
    final services = data?.services ?? const <BackendServiceInfo>[];
    final visibleServices = services.take(6).toList();
    final running = state.running;
    final statusText = _backendServiceStatusText(state);
    final statusColor = _backendServiceStatusColor(state);
    final updatedText = data?.timestamp == null
        ? (running ? '等待服务状态' : '手动启动监控')
        : '更新于 ${_formatDashboardTimeToSecond(data!.timestamp!)}';

    return _buildBeautyCard(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('后台服务状态', style: _phoneTitleStyle(17))),
              shadcn.Card(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                filled: true,
                fillColor: statusColor.withValues(alpha: 0.12),
                borderColor: statusColor.withValues(alpha: 0.16),
                child: Text(
                  statusText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: shadcn.Theme.of(
                    context,
                  ).typography.xSmall.copyWith(color: statusColor, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 8),
              shadcn.IconButton.ghost(
                onPressed: () => ref.read(backendServiceStatusProvider.notifier).toggle(),
                icon: Icon(running ? shadcn.LucideIcons.pause : shadcn.LucideIcons.play, size: 17),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            [
              if ((data?.source ?? '').isNotEmpty) data!.source,
              updatedText,
              if ((data?.connectionId ?? '').isNotEmpty) data!.connectionId,
            ].join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: shadcn.Theme.of(
              context,
            ).typography.xSmall.copyWith(color: cs.mutedForeground, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildBackendServiceSummaryPill('总数', '${summary.total}', cs.foreground)),
              const SizedBox(width: 8),
              Expanded(child: _buildBackendServiceSummaryPill('运行', '${summary.running}', _phoneSuccessColor)),
              const SizedBox(width: 8),
              Expanded(child: _buildBackendServiceSummaryPill('停止', '${summary.stopped}', _phoneWarningColor)),
              const SizedBox(width: 8),
              Expanded(child: _buildBackendServiceSummaryPill('失败', '${summary.failed}', _phoneErrorColor)),
            ],
          ),
          const SizedBox(height: 12),
          if (state.error != null)
            _buildBackendServiceMessage(state.error!, _phoneErrorColor)
          else if (services.isEmpty)
            _buildBackendServiceMessage(running ? '正在等待后台服务状态推送' : '监控已暂停', cs.mutedForeground)
          else
            Column(
              children: [
                for (var i = 0; i < visibleServices.length; i++) ...[
                  _buildBackendServiceRow(visibleServices[i]),
                  if (i != visibleServices.length - 1) const SizedBox(height: 8),
                ],
              ],
            ),
          if ((data?.errors ?? const <String>[]).isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildBackendServiceMessage(data!.errors.first, _phoneErrorColor),
          ],
        ],
      ),
    );
  }

  Widget _buildBackendServiceSummaryPill(String label, String value, Color color) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return shadcn.Card(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      filled: true,
      fillColor: color.withValues(alpha: 0.07),
      borderColor: color.withValues(alpha: 0.12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: shadcn.Theme.of(
              context,
            ).typography.xSmall.copyWith(color: cs.mutedForeground, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: shadcn.Theme.of(
              context,
            ).typography.large.copyWith(color: color, fontWeight: FontWeight.w900, height: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildBackendServiceRow(BackendServiceInfo service) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final color = _backendServiceStateColor(service.state);
    final uptime = _formatBackendServiceUptime(service.uptime);
    final subtitle = service.running && service.pid > 0
        ? '运行 $uptime · pid ${service.pid}'
        : service.description.isNotEmpty
        ? service.description
        : 'pid ${service.pid}';

    return shadcn.Card(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      filled: true,
      fillColor: cs.muted.withValues(alpha: 0.24),
      borderColor: cs.border.withValues(alpha: 0.28),
      child: Row(
        children: [
          Icon(shadcn.LucideIcons.circle, size: 8, color: color),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: shadcn.Theme.of(
                    context,
                  ).typography.xSmall.copyWith(color: cs.foreground, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: shadcn.Theme.of(
                    context,
                  ).typography.xSmall.copyWith(color: cs.mutedForeground, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            service.state.isEmpty ? '-' : service.state,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: shadcn.Theme.of(context).typography.xSmall.copyWith(color: color, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _buildBackendServiceMessage(String text, Color color) {
    return SizedBox(
      width: double.infinity,
      child: shadcn.Card(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        filled: true,
        fillColor: color.withValues(alpha: 0.08),
        borderColor: color.withValues(alpha: 0.14),
        child: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: shadcn.Theme.of(context).typography.xSmall.copyWith(color: color, fontWeight: FontWeight.w700),
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
    final cs = shadcn.Theme.of(context).colorScheme;
    if (state.error != null) return _phoneErrorColor;
    final data = state.data;
    if (data?.healthy == true) return _phoneSuccessColor;
    if (data?.hasIssue == true) return _phoneWarningColor;
    return state.running ? _phoneSuccessColor : cs.mutedForeground;
  }

  Color _backendServiceStateColor(String state) {
    final cs = shadcn.Theme.of(context).colorScheme;
    switch (state.toUpperCase()) {
      case 'RUNNING':
        return _phoneSuccessColor;
      case 'STOPPED':
      case 'EXITED':
        return _phoneWarningColor;
      case 'FATAL':
      case 'FAILED':
      case 'BACKOFF':
        return _phoneErrorColor;
      default:
        return cs.mutedForeground;
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

  _DesignationProgress _phoneDesignationProgress(int siteCount) {
    final levels = _DashboardPageState._designations.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
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

  Widget _buildBeautyCard({required Widget child, EdgeInsetsGeometry padding = const EdgeInsets.all(16)}) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    return SizedBox(
      width: double.infinity,
      child: shadcn.Card(
        filled: true,
        fillColor: cs.card,
        borderColor: cs.border.withValues(alpha: 0.72),
        borderRadius: theme.borderRadiusXl,
        padding: padding,
        child: child,
      ),
    );
  }

  Widget _buildPhoneOverviewCard(DashboardData data) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final accountAge = _showAccountAgeWeeks
        ? _formatAccountAgeWeeks(data.earliestSite?.timeJoin)
        : _formatAccountAgeYears(data.earliestSite?.timeJoin);
    final lastRefresh = formatDateStringToMinute(data.updatedAt, empty: '-');
    final overallItems = [
      _StatItem('做种数', '${data.totalSeeding}', shadcn.LucideIcons.users, _phoneSuccessColor),
      _StatItem('下载数', '${data.totalLeeching}', shadcn.LucideIcons.download, _phoneCpuChartColor),
      _StatItem('做种量', formatBytes(data.totalSeedVol), shadcn.LucideIcons.database, _phoneMemoryChartColor),
      _StatItem('发种数', _formatCount(data.totalPublished), shadcn.LucideIcons.star, _phoneWarningColor),
    ];

    return _buildBeautyCard(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('数据总览', style: _phoneTitleStyle(17))),
              Text(
                '更新于 $lastRefresh',
                style: shadcn.Theme.of(
                  context,
                ).typography.xSmall.copyWith(fontWeight: FontWeight.w700, color: cs.mutedForeground),
              ),
              const SizedBox(width: 8),
              Icon(shadcn.LucideIcons.refreshCw, size: 16, color: cs.primary),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth < 360 ? 2 : 4;
              const spacing = 10.0;
              final itemWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: 10,
                children: [
                  _buildOverviewStatTile(
                    width: itemWidth,
                    label: '总上传',
                    value: formatBytes(data.totalUploaded),
                    caption: '较昨日 +${formatBytes(data.todayUploadIncrement)}',
                    icon: shadcn.LucideIcons.arrowUp,
                    color: _phoneUploadChartColor,
                  ),
                  _buildOverviewStatTile(
                    width: itemWidth,
                    label: '总下载',
                    value: formatBytes(data.totalDownloaded),
                    caption: '较昨日 +${formatBytes(data.todayDownloadIncrement)}',
                    icon: shadcn.LucideIcons.arrowDown,
                    color: _phoneDownloadChartColor,
                  ),
                  _buildOverviewStatTile(
                    width: itemWidth,
                    label: 'P龄',
                    value: accountAge,
                    caption: _showAccountAgeWeeks ? '按周显示' : '按年显示',
                    icon: shadcn.LucideIcons.calendar,
                    color: _phoneCpuChartColor,
                    tooltip: 'P龄\n当前：$accountAge\n点击切换年/周显示',
                    onTap: () => setState(() => _showAccountAgeWeeks = !_showAccountAgeWeeks),
                  ),
                  _buildOverviewStatTile(
                    width: itemWidth,
                    label: '站点数',
                    value: '${data.siteCount.toInt()}',
                    caption: '在线 ${data.statusList.length}',
                    icon: shadcn.LucideIcons.globe,
                    color: _phoneMemoryChartColor,
                    tooltip: '站点数\n总计：${data.siteCount.toInt()} 个\n当前列表：${data.statusList.length} 个',
                  ),
                  ...overallItems.map(
                    (item) => _buildOverviewStatTile(
                      width: itemWidth,
                      label: item.label,
                      value: item.value,
                      caption: '累计数据',
                      icon: item.icon,
                      color: item.color,
                      tooltip: '${item.label}\n${item.value}',
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStatTile({
    required double width,
    required String label,
    required String value,
    required String caption,
    required IconData icon,
    required Color color,
    String? tooltip,
    VoidCallback? onTap,
  }) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          height: 92,
          child: shadcn.Card(
            padding: const EdgeInsets.all(10),
            filled: true,
            fillColor: color.withValues(alpha: 0.055),
            borderColor: color.withValues(alpha: 0.10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _DashboardIconTooltip(
                      message: tooltip ?? '$label\n$value\n$caption',
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: shadcn.Card(
                          padding: EdgeInsets.zero,
                          filled: true,
                          fillColor: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                          borderColor: color.withValues(alpha: 0.08),
                          child: Icon(icon, size: 14, color: color),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _phonePrimaryTextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: shadcn.Theme.of(
                    context,
                  ).typography.xSmall.copyWith(fontSize: 13, fontWeight: FontWeight.w900, color: color, height: 1),
                ),
                const SizedBox(height: 5),
                Text(
                  caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: shadcn.Theme.of(
                    context,
                  ).typography.xSmall.copyWith(fontWeight: FontWeight.w700, color: cs.mutedForeground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneQuickActionsCard() {
    return _buildBeautyCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Row(
        children: [
          _buildActionShortcut(
            '抓取数据',
            '刷新站点数据',
            shadcn.LucideIcons.refreshCw,
            _phoneTreemapChartColor(5),
            _hasRunningSummaryAction ? null : _refreshSiteData,
            _isRefreshingSiteData,
          ),
          _buildActionShortcut(
            '拉取数据',
            '拉取Docker数据',
            shadcn.LucideIcons.rotateCw,
            _phoneCpuChartColor,
            _hasRunningSummaryAction ? null : _refreshDashboardData,
            _isRefreshingDashboardData,
          ),
          _buildActionShortcut(
            '签到任务',
            '领取每日奖励',
            shadcn.LucideIcons.calendarCheck,
            _phoneWarningColor,
            _hasRunningSummaryAction ? null : _signInSites,
            _isSigningInSites,
          ),
        ],
      ),
    );
  }

  Widget _buildActionShortcut(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback? onTap,
    bool loading,
  ) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: 102,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: shadcn.Card(
                  padding: EdgeInsets.zero,
                  filled: true,
                  fillColor: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  borderColor: color.withValues(alpha: 0.10),
                  child: loading
                      ? shadcn.CircularProgressIndicator(size: 22, color: color)
                      : Icon(icon, size: 27, color: color),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _phonePrimaryTextStyle(fontSize: 14, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: shadcn.Theme.of(
                  context,
                ).typography.xSmall.copyWith(fontWeight: FontWeight.w700, color: cs.mutedForeground),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneTrendCard(DashboardData data, bool privacy) {
    final isToday = _phoneTrendDays == 1;
    final trendPoints = _buildPhoneTrendPoints(data, privacy);
    final uploadTotal = trendPoints.fold<num>(0, (sum, point) => sum + point.upload);
    final downloadTotal = trendPoints.fold<num>(0, (sum, point) => sum + point.download);

    return _buildBeautyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('上传 / 下载趋势', style: _phoneTitleStyle(17))),
              _buildRangeChip('今日', isToday, () => _setPhoneTrendDays(1)),
              _buildRangeChip('本周', _phoneTrendDays == 7, () => _setPhoneTrendDays(7)),
              _buildRangeChip('本月', _phoneTrendDays == 30, () => _setPhoneTrendDays(30)),
            ],
          ),
          const SizedBox(height: 18),
          if (isToday)
            _buildPhoneTodaySitePieSection(data, privacy)
          else
            Row(
              children: [
                Expanded(
                  child: _buildTrendHalf(
                    '上传量',
                    formatBytes(uploadTotal),
                    shadcn.LucideIcons.arrowUp,
                    _phoneUploadChartColor,
                    trendPoints,
                    (point) => point.upload,
                    (point) => point.uploadDetails,
                    '上传',
                  ),
                ),
                SizedBox(
                  height: 116,
                  child: VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: shadcn.Theme.of(context).colorScheme.border.withValues(alpha: 0.55),
                  ),
                ),
                Expanded(
                  child: _buildTrendHalf(
                    '下载量',
                    formatBytes(downloadTotal),
                    shadcn.LucideIcons.arrowDown,
                    _phoneDownloadChartColor,
                    trendPoints,
                    (point) => point.download,
                    (point) => point.downloadDetails,
                    '下载',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPhoneTodaySitePieSection(DashboardData data, bool privacy) {
    final uploadItems = _buildKvDistributionItems(data.uploadIncrementDataList, privacy, valueFormatter: formatBytes);
    final downloadItems = _buildKvDistributionItems(
      data.downloadIncrementDataList,
      privacy,
      valueFormatter: formatBytes,
      colorOffset: 1,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildTodaySitePieBlock('今日上传', uploadItems, data.todayUploadIncrement)),
        const SizedBox(width: 14),
        Expanded(child: _buildTodaySitePieBlock('今日下载', downloadItems, data.todayDownloadIncrement)),
      ],
    );
  }

  Widget _buildTodaySitePieBlock(String title, List<_DistributionItem> items, num fallbackTotal) {
    final total = items.fold<num>(0, (sum, item) => sum + item.value);
    final displayTotal = total > 0 ? total : fallbackTotal;
    final chartItems = _compactDistributionItems(items, 8, total);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _phoneTitleStyle(14)),
        const SizedBox(height: 4),
        Text(
          formatBytes(displayTotal),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: shadcn.Theme.of(context).typography.xSmall.copyWith(
            fontWeight: FontWeight.w900,
            color: shadcn.Theme.of(context).colorScheme.mutedForeground,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 87,
          child: _buildTodaySiteDonutChart(
            chartItems,
            total,
            centerLabel: title.replaceFirst('今日', ''),
            empty: items.isEmpty,
            tooltip: _buildTodaySiteSummaryTooltip(items, displayTotal),
          ),
        ),
      ],
    );
  }

  List<_DistributionItem> _compactDistributionItems(List<_DistributionItem> items, int limit, num total) {
    if (items.length <= limit) return items;
    final visible = items.take(limit - 1).toList();
    final hidden = items.skip(limit - 1).toList();
    final otherValue = hidden.fold<num>(0, (sum, item) => sum + item.value);
    return [
      ...visible,
      _DistributionItem(
        name: '其他 ${hidden.length} 项',
        value: otherValue,
        color: _phoneTreemapChartColor(limit - 1),
        valueText: formatBytes(otherValue),
        tooltip: _buildDistributionTooltip('其他 ${hidden.length} 项', otherValue, total, formatBytes, children: hidden),
      ),
    ];
  }

  Widget _buildTodaySiteDonutChart(
    List<_DistributionItem> items,
    num total, {
    required String centerLabel,
    bool empty = false,
    required String tooltip,
  }) {
    if (empty) {
      return _buildEmptyTodaySiteDonut(centerLabel, tooltip: tooltip);
    }

    return Center(
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) {
          _rememberDashboardTooltipPosition(event);
          _scheduleDashboardOverlayTooltip(tooltip);
        },
        child: SizedBox.square(
          dimension: 86,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SfCircularChart(
                margin: EdgeInsets.zero,
                series: <DoughnutSeries<_DistributionItem, String>>[
                  DoughnutSeries<_DistributionItem, String>(
                    animationDuration: _phoneChartAnimationDuration,
                    dataSource: items,
                    xValueMapper: (item, _) => item.name,
                    yValueMapper: (item, _) => item.value,
                    pointColorMapper: (item, _) => item.color,
                    radius: '96%',
                    innerRadius: '62%',
                    dataLabelSettings: const DataLabelSettings(isVisible: false),
                  ),
                ],
              ),
              IgnorePointer(
                child: Text(
                  centerLabel,
                  style: shadcn.Theme.of(context).typography.small.copyWith(
                    fontWeight: FontWeight.w900,
                    color: shadcn.Theme.of(context).colorScheme.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTodaySiteDonut(String centerLabel, {required String tooltip}) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final ringColor = cs.mutedForeground.withValues(alpha: 0.18);
    return Center(
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) {
          _rememberDashboardTooltipPosition(event);
          _scheduleDashboardOverlayTooltip(tooltip);
        },
        child: SizedBox.square(
          dimension: 86,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SfCircularChart(
                margin: EdgeInsets.zero,
                series: <DoughnutSeries<_PieData, String>>[
                  DoughnutSeries<_PieData, String>(
                    animationDuration: _phoneChartAnimationDuration,
                    dataSource: [_PieData(name: centerLabel, value: 1, tooltip: tooltip, color: ringColor)],
                    xValueMapper: (item, _) => item.name,
                    yValueMapper: (item, _) => item.value,
                    pointColorMapper: (item, _) => item.color,
                    radius: '96%',
                    innerRadius: '64%',
                    dataLabelSettings: const DataLabelSettings(isVisible: false),
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    centerLabel,
                    style: shadcn.Theme.of(
                      context,
                    ).typography.small.copyWith(fontWeight: FontWeight.w900, color: cs.mutedForeground),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '无数据',
                    style: shadcn.Theme.of(context).typography.xSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.mutedForeground.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildTodaySiteSummaryTooltip(List<_DistributionItem> items, num total) {
    final rows = [...items]..sort((a, b) => b.value.compareTo(a.value));
    return [
      '__NO_HEADER__',
      '今日汇总\t${formatBytes(total)}',
      ...rows.map((item) => '${item.name}\t${item.valueText ?? formatBytes(item.value)}'),
    ].join('\n');
  }

  Widget _buildRangeChip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: selected
          ? shadcn.Button.primary(onPressed: onTap, child: Text(label))
          : shadcn.Button.secondary(
              onPressed: onTap,
              child: Text(
                label,
                style: shadcn.Theme.of(context).typography.xSmall.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
    );
  }

  Widget _buildTrendHalf(
    String label,
    String value,
    IconData icon,
    Color color,
    List<_TrendPoint> points,
    num Function(_TrendPoint point) valueOf,
    List<MapEntry<String, num>> Function(_TrendPoint point) detailsOf,
    String tooltipLabel,
  ) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: shadcn.Card(
                  padding: EdgeInsets.zero,
                  filled: true,
                  fillColor: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  borderColor: color.withValues(alpha: 0.10),
                  child: Icon(icon, size: 18, color: color),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: shadcn.Theme.of(
                    context,
                  ).typography.xSmall.copyWith(fontWeight: FontWeight.w800, color: cs.mutedForeground),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: _phoneTitleStyle(19)),
          ),
          const SizedBox(height: 20),
          SizedBox(height: 58, child: _buildSparkBars(points, color, valueOf, detailsOf, tooltipLabel)),
        ],
      ),
    );
  }

  Widget _buildSparkBars(
    List<_TrendPoint> rawPoints,
    Color color,
    num Function(_TrendPoint point) valueOf,
    List<MapEntry<String, num>> Function(_TrendPoint point) detailsOf,
    String tooltipLabel,
  ) {
    final points = rawPoints.where((point) => valueOf(point) > 0).take(24).toList();
    if (points.isEmpty) {
      return Center(child: this._buildPanelEmpty(compact: true));
    }
    final maxValue = points.fold<num>(0, (max, point) => valueOf(point) > max ? valueOf(point) : max);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: points.map((point) {
        final value = valueOf(point);
        final ratio = maxValue <= 0 ? 0.0 : (value / maxValue).toDouble();
        return Expanded(
          child: Listener(
            onPointerDown: (event) {
              _hideDashboardOverlayTooltip();
              _rememberDashboardTooltipPosition(event);
              _scheduleDashboardOverlayTooltip(_buildTrendTooltipText(point, value, detailsOf(point), tooltipLabel));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: FractionallySizedBox(
                heightFactor: ratio.clamp(0.16, 1.0).toDouble(),
                alignment: Alignment.bottomCenter,
                child: shadcn.Card(
                  padding: EdgeInsets.zero,
                  filled: true,
                  fillColor: color.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.vertical(top: shadcn.Theme.of(context).radiusXsRadius),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatTrendDate(String date) {
    if (date.length >= 10) return date;
    return _formatMonth(date);
  }

  String _buildTrendTooltipText(_TrendPoint point, num value, List<MapEntry<String, num>> details, String label) {
    return [
      '📅 ${_formatTrendDate(point.date)} · $label',
      '汇总\t${formatBytes(value)}',
      ...details.map((item) => '${item.key}\t${formatBytes(item.value)}'),
    ].join('\n');
  }

  Widget _buildPhoneUploadDistributionCard(DashboardData data, bool privacy) {
    final items = _buildUploadDistributionItems(data, privacy);
    final top = items.take(_DashboardPageState._phoneDistributionLimit).toList();
    final otherItems = items.skip(_DashboardPageState._phoneDistributionLimit).toList();
    final otherValue = items
        .skip(_DashboardPageState._phoneDistributionLimit)
        .fold<num>(0, (sum, item) => sum + item.value);
    final total = items.fold<num>(0, (sum, item) => sum + item.value);
    final displayItems = [
      ...top,
      if (otherValue > 0)
        _DistributionItem(
          name: '其他 ${items.length - top.length} 个站点',
          value: otherValue,
          color: _phoneTreemapChartColor(top.length),
          valueText: formatBytes(otherValue),
          tooltip: _buildDistributionTooltip(
            '其他 ${items.length - top.length} 个站点',
            otherValue,
            total,
            formatBytes,
            children: otherItems,
          ),
        ),
    ];

    return _buildBeautyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('上传量分布', style: _phoneTitleStyle(17))),
              Text(
                formatBytes(total),
                style: shadcn.Theme.of(context).typography.small.copyWith(
                  fontWeight: FontWeight.w900,
                  color: shadcn.Theme.of(context).colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (displayItems.isEmpty)
            this._buildPanelEmpty()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 520;
                final chart = SizedBox(
                  width: stacked ? constraints.maxWidth : 220,
                  height: 204,
                  child: _buildDistributionDonut(displayItems, total),
                );
                final list = Expanded(
                  child: Column(children: displayItems.map((item) => _buildDistributionListRow(item, total)).toList()),
                );
                if (stacked) {
                  return Column(
                    children: [
                      chart,
                      const SizedBox(height: 8),
                      ...displayItems.map((item) => _buildDistributionListRow(item, total)),
                    ],
                  );
                }
                return Row(children: [chart, const SizedBox(width: 18), list]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPhoneUserDistributionCard(DashboardData data, bool privacy) {
    final emailItems = _buildKvDistributionItems(data.emailCount, privacy);
    final usernameItems = _buildKvDistributionItems(data.usernameCount, privacy);
    return _buildBeautyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('用户信息分布', style: _phoneTitleStyle(17)),
          const SizedBox(height: 16),
          _buildMiniDonutChartBlock('邮箱', emailItems),
          const SizedBox(height: 18),
          _buildMiniDonutChartBlock('用户名', usernameItems),
        ],
      ),
    );
  }

  Widget _buildPhoneTodayIncrementCard(DashboardData data, bool privacy) {
    final chartItems = _buildIncrementChartItems(data, privacy);
    final rangeLabel = switch (_phoneTrendDays) {
      1 => '当日',
      7 => '本周',
      _ => '本月',
    };
    final rangeCaption = _phoneTrendDays == 1 ? '今日' : '近$_phoneTrendDays天';
    return _buildBeautyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$rangeLabel增量排行',
                  style: _phonePrimaryTextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                rangeCaption,
                style: shadcn.Theme.of(context).typography.xSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: shadcn.Theme.of(context).colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: chartItems.length <= 4 ? 214 : 276,
            child: chartItems.isEmpty ? this._buildPanelEmpty() : _buildIncrementBarChart(chartItems),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneSeedDistributionCard(DashboardData data, bool privacy) {
    final items = _buildSeedDistributionItems(data.seedDataList, privacy);
    return _buildPhoneGenericDistributionCard(
      title: '做种分布',
      centerLabel: '总做种',
      items: items,
      totalFormatter: formatBytes,
      compactOverflow: false,
      legendLimit: _DashboardPageState._phoneDistributionLimit,
    );
  }

  List<_DistributionItem> _buildSeedDistributionItems(List<KV> data, bool privacy) {
    final sorted = data.where((e) => e.value > 0).toList()..sort((a, b) => b.value.compareTo(a.value));
    if (sorted.isEmpty) return const [];

    final total = sorted.fold<num>(0, (sum, item) => sum + item.value);
    final average = total / sorted.length;
    final normal = sorted.where((item) => item.value >= average).toList();
    final belowAverage = sorted.where((item) => item.value < average).toList();

    final items = [
      for (var i = 0; i < normal.length; i++)
        _DistributionItem(
          name: _mask(normal[i].name, privacy),
          value: normal[i].value,
          color: _phoneTreemapChartColor(i),
          valueText: formatBytes(normal[i].value),
        ),
    ];

    if (belowAverage.isNotEmpty) {
      final lowTotal = belowAverage.fold<num>(0, (sum, item) => sum + item.value);
      final children = [
        for (var i = 0; i < belowAverage.length; i++)
          _DistributionItem(
            name: _mask(belowAverage[i].name, privacy),
            value: belowAverage[i].value,
            color: _phoneTreemapChartColor(normal.length + i),
            valueText: formatBytes(belowAverage[i].value),
          ),
      ];
      items.add(
        _DistributionItem(
          name: '低于平均 ${belowAverage.length} 个站点',
          value: lowTotal,
          color: shadcn.Theme.of(context).colorScheme.mutedForeground.withValues(alpha: 0.72),
          valueText: formatBytes(lowTotal),
          tooltip: _buildDistributionTooltip(
            '低于平均 ${belowAverage.length} 个站点',
            lowTotal,
            total,
            formatBytes,
            valueText: formatBytes(lowTotal),
            children: children,
          ),
        ),
      );
    }

    return items;
  }

  Widget _buildPhoneMonthlyMetricCard({
    required String title,
    required List<MonthSiteData> data,
    required num Function(StatusRecord record) getValue,
    required String Function(num value) formatValue,
    required Color color,
    required bool privacy,
  }) {
    final totals = <String, num>{};
    final siteDetails = <String, List<MapEntry<String, num>>>{};
    for (final site in data) {
      for (final record in site.value) {
        final value = getValue(record);
        totals[record.createdAt] = (totals[record.createdAt] ?? 0) + value;
        if (value > 0) {
          siteDetails.putIfAbsent(record.createdAt, () => []).add(MapEntry(_mask(site.name, privacy), value));
        }
      }
    }
    final entries = totals.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final visible = entries.length > 12 ? entries.sublist(entries.length - 12) : entries;
    final total = visible.fold<num>(0, (sum, entry) => sum + entry.value);
    final chartItems = visible.map((entry) {
      final details = [...siteDetails[entry.key] ?? const <MapEntry<String, num>>[]]
        ..sort((a, b) => b.value.compareTo(a.value));
      final tooltipLines = [
        title,
        _formatMonth(entry.key),
        '汇总\t${formatValue(entry.value)}',
        ...details.map((item) => '${item.key}\t${formatValue(item.value)}'),
      ];
      return _MonthlyChartItem(_formatMonth(entry.key), entry.value, formatValue(entry.value), tooltipLines.join('\n'));
    }).toList();
    return _buildBeautyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: _phoneTitleStyle(17))),
              Text(
                formatValue(total),
                style: shadcn.Theme.of(context).typography.small.copyWith(
                  fontWeight: FontWeight.w900,
                  color: shadcn.Theme.of(context).colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(height: 176, child: _buildMonthlyColumnChart(chartItems, color, formatValue)),
        ],
      ),
    );
  }

  Widget _buildMonthlyColumnChart(
    List<_MonthlyChartItem> chartItems,
    Color color,
    String Function(num value) formatValue,
  ) {
    if (chartItems.isEmpty) return this._buildPanelEmpty(compact: true);
    final cs = shadcn.Theme.of(context).colorScheme;

    return Listener(
      onPointerDown: _rememberDashboardTooltipPosition,
      child: SfCartesianChart(
        margin: EdgeInsets.zero,
        plotAreaBorderWidth: 0,
        primaryXAxis: CategoryAxis(
          labelStyle: shadcn.Theme.of(
            context,
          ).typography.xSmall.copyWith(fontSize: 10, fontWeight: FontWeight.w700, color: cs.mutedForeground),
          axisLine: const AxisLine(width: 0),
          majorGridLines: const MajorGridLines(width: 0),
          majorTickLines: const MajorTickLines(size: 0),
          labelIntersectAction: AxisLabelIntersectAction.wrap,
        ),
        primaryYAxis: NumericAxis(
          labelStyle: shadcn.Theme.of(context).typography.xSmall.copyWith(fontSize: 10, color: cs.mutedForeground),
          axisLine: const AxisLine(width: 0),
          majorTickLines: const MajorTickLines(size: 0),
          majorGridLines: MajorGridLines(width: 0.5, color: cs.border.withValues(alpha: 0.45)),
          axisLabelFormatter: (details) => ChartAxisLabel(formatValue(details.value), details.textStyle),
        ),
        series: <CartesianSeries<_MonthlyChartItem, String>>[
          ColumnSeries<_MonthlyChartItem, String>(
            animationDuration: _phoneChartAnimationDuration,
            dataSource: chartItems,
            xValueMapper: (item, _) => item.label,
            yValueMapper: (item, _) => item.value,
            pointColorMapper: (_, index) => color.withValues(alpha: index.isEven ? 0.86 : 0.62),
            borderRadius: BorderRadius.vertical(top: shadcn.Theme.of(context).radiusSmRadius),
            width: 0.58,
            spacing: 0.1,
            dataLabelMapper: (item, _) => item.displayValue,
          ),
        ],
        tooltipBehavior: TooltipBehavior(
          enable: true,
          activationMode: ActivationMode.singleTap,
          header: '',
          canShowMarker: false,
          builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) =>
              _buildDashboardOverlayTooltip((data as _MonthlyChartItem).tooltip),
        ),
      ),
    );
  }

  Widget _buildPhoneGenericDistributionCard({
    required String title,
    required String centerLabel,
    required List<_DistributionItem> items,
    required String Function(num value) totalFormatter,
    bool compactOverflow = true,
    int? legendLimit,
  }) {
    final total = items.fold<num>(0, (sum, item) => sum + item.value);
    final top = items.take(_DashboardPageState._phoneDistributionLimit).toList();
    final otherItems = items.skip(_DashboardPageState._phoneDistributionLimit).toList();
    final otherValue = otherItems.fold<num>(0, (sum, item) => sum + item.value);
    final chartItems = compactOverflow
        ? [
            ...top,
            if (otherValue > 0)
              _DistributionItem(
                name: '其他 ${items.length - top.length} 项',
                value: otherValue,
                color: shadcn.Theme.of(context).colorScheme.mutedForeground.withValues(alpha: 0.72),
                valueText: totalFormatter(otherValue),
                tooltip: _buildDistributionTooltip(
                  '其他 ${items.length - top.length} 项',
                  otherValue,
                  total,
                  totalFormatter,
                  children: otherItems,
                ),
              ),
          ]
        : items;
    final legendItems = legendLimit == null ? chartItems : chartItems.take(legendLimit).toList();
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;
    return _buildBeautyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: _phoneTitleStyle(17))),
              Text(totalFormatter(total), style: typo.small.copyWith(color: cs.mutedForeground, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 16),
          if (chartItems.isEmpty)
            this._buildPanelEmpty()
          else ...[
            SizedBox(
              height: 204,
              child: _buildDistributionDonut(
                chartItems,
                total,
                centerLabel: centerLabel,
                totalFormatter: totalFormatter,
              ),
            ),
            const SizedBox(height: 8),
            ...legendItems.map((item) => _buildDistributionListRow(item, total)),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniDonutChartBlock(String title, List<_DistributionItem> items) {
    final top = items.take(_DashboardPageState._phoneDistributionLimit).toList();
    final otherItems = items.skip(_DashboardPageState._phoneDistributionLimit).toList();
    final otherValue = items
        .skip(_DashboardPageState._phoneDistributionLimit)
        .fold<num>(0, (sum, item) => sum + item.value);
    final total = items.fold<num>(0, (sum, item) => sum + item.value);
    final displayItems = [
      ...top,
      if (otherValue > 0)
        _DistributionItem(
          name: '其他 ${items.length - top.length} 项',
          value: otherValue,
          color: _phoneTreemapChartColor(top.length),
          valueText: '${_formatCount(otherValue)}',
          tooltip: _buildDistributionTooltip(
            '其他 ${items.length - top.length} 项',
            otherValue,
            total,
            (value) => _formatCount(value),
            children: otherItems,
          ),
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _phoneTitleStyle(14)),
        const SizedBox(height: 10),
        if (displayItems.isEmpty)
          this._buildPanelEmpty(compact: true)
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final chart = SizedBox(
                width: 112,
                height: 112,
                child: _buildDistributionDonut(
                  displayItems,
                  total,
                  centerLabel: title,
                  totalFormatter: (value) => _formatCount(value),
                ),
              );
              final list = Column(
                children: displayItems.map((item) => _buildDistributionListRow(item, total)).toList(),
              );

              if (constraints.maxWidth < 300) {
                return Column(children: [chart, const SizedBox(height: 6), list]);
              }

              return Row(
                children: [
                  chart,
                  const SizedBox(width: 8),
                  Expanded(child: list),
                ],
              );
            },
          ),
      ],
    );
  }

  List<_IncrementChartItem> _buildIncrementChartItems(DashboardData data, bool privacy) {
    final dates = _phoneVisibleDateKeys(data).toSet();
    if (dates.isNotEmpty) {
      final items = <_IncrementChartItem>[];
      for (final site in data.uploadMonthIncrementDataList) {
        num upload = 0;
        num download = 0;
        for (final record in site.value) {
          if (!dates.contains(record.createdAt.trim())) continue;
          upload += record.uploaded;
          download += record.downloaded;
        }
        if (upload > 0 || download > 0) {
          items.add(
            _IncrementChartItem(
              _mask(site.name, privacy),
              upload,
              download,
              '上传\t${formatBytes(upload)}\n下载\t${formatBytes(download)}',
            ),
          );
        }
      }
      items.sort((a, b) => (b.upload + b.download).compareTo(a.upload + a.download));
      return items.take(10).toList();
    }

    final names = <String>{};
    for (final item in data.uploadIncrementDataList) {
      if (item.value > 0) names.add(item.name);
    }
    for (final item in data.downloadIncrementDataList) {
      if (item.value > 0) names.add(item.name);
    }
    final items = names.map((name) {
      num upload = 0;
      num download = 0;
      for (final item in data.uploadIncrementDataList) {
        if (item.name == name) upload = item.value;
      }
      for (final item in data.downloadIncrementDataList) {
        if (item.name == name) download = item.value;
      }
      return _IncrementChartItem(
        _mask(name, privacy),
        upload,
        download,
        '上传\t${formatBytes(upload)}\n下载\t${formatBytes(download)}',
      );
    }).toList()..sort((a, b) => (b.upload + b.download).compareTo(a.upload + a.download));
    return items.take(10).toList();
  }

  Widget _buildIncrementBarChart(List<_IncrementChartItem> items) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Listener(
      onPointerDown: _rememberDashboardTooltipPosition,
      child: SfCartesianChart(
        margin: EdgeInsets.zero,
        plotAreaBorderWidth: 0,
        legend: Legend(
          isVisible: true,
          position: LegendPosition.bottom,
          overflowMode: LegendItemOverflowMode.wrap,
          textStyle: shadcn.Theme.of(context).typography.xSmall.copyWith(fontSize: 11, color: cs.mutedForeground),
        ),
        primaryXAxis: CategoryAxis(
          labelStyle: shadcn.Theme.of(
            context,
          ).typography.xSmall.copyWith(fontSize: 10, fontWeight: FontWeight.w700, color: cs.mutedForeground),
          axisLine: const AxisLine(width: 0),
          majorGridLines: const MajorGridLines(width: 0),
          majorTickLines: const MajorTickLines(size: 0),
          labelIntersectAction: AxisLabelIntersectAction.wrap,
        ),
        primaryYAxis: NumericAxis(
          labelStyle: shadcn.Theme.of(context).typography.xSmall.copyWith(fontSize: 10, color: cs.mutedForeground),
          axisLine: const AxisLine(width: 0),
          majorTickLines: const MajorTickLines(size: 0),
          majorGridLines: MajorGridLines(width: 0.5, color: cs.border.withValues(alpha: 0.5)),
          axisLabelFormatter: (details) => ChartAxisLabel(formatYAxis(details.value), details.textStyle),
        ),
        series: <CartesianSeries<_IncrementChartItem, String>>[
          BarSeries<_IncrementChartItem, String>(
            animationDuration: _phoneChartAnimationDuration,
            dataSource: items,
            xValueMapper: (item, _) => item.name,
            yValueMapper: (item, _) => item.upload,
            name: '上传',
            color: _phoneUploadChartColor,
            borderRadius: BorderRadius.horizontal(right: shadcn.Theme.of(context).radiusSmRadius),
            width: 0.62,
            spacing: 0.18,
          ),
          BarSeries<_IncrementChartItem, String>(
            animationDuration: _phoneChartAnimationDuration,
            dataSource: items,
            xValueMapper: (item, _) => item.name,
            yValueMapper: (item, _) => item.download,
            name: '下载',
            color: _phoneDownloadChartColor,
            borderRadius: BorderRadius.horizontal(right: shadcn.Theme.of(context).radiusSmRadius),
            width: 0.62,
            spacing: 0.18,
          ),
        ],
        tooltipBehavior: TooltipBehavior(
          enable: true,
          activationMode: ActivationMode.singleTap,
          header: '',
          canShowMarker: false,
          builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) =>
              _buildDashboardOverlayTooltip(
                '${(data as _IncrementChartItem).name}\n${(data as _IncrementChartItem).tooltip}',
              ),
        ),
      ),
    );
  }

  Widget _buildCompactDistributionBlock(String title, List<_DistributionItem> items) {
    final total = items.fold<num>(0, (sum, item) => sum + item.value);
    final top = items.take(4).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: _phoneTitleStyle(14))),
            Text(
              _formatCount(total),
              style: shadcn.Theme.of(context).typography.xSmall.copyWith(
                fontWeight: FontWeight.w900,
                color: shadcn.Theme.of(context).colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (top.isEmpty)
          this._buildPanelEmpty(compact: true)
        else
          ...top.map((item) => _buildDistributionListRow(item, total)),
      ],
    );
  }

  List<_DistributionItem> _buildUploadDistributionItems(DashboardData data, bool privacy) {
    final sorted = data.statusList.where((e) => e.value.uploaded > 0).toList()
      ..sort((a, b) => b.value.uploaded.compareTo(a.value.uploaded));
    return [
      for (var i = 0; i < sorted.length; i++)
        _DistributionItem(
          name: _mask(sorted[i].name, privacy),
          value: sorted[i].value.uploaded,
          color: _phoneTreemapChartColor(i),
          valueText: formatBytes(sorted[i].value.uploaded),
        ),
    ];
  }

  List<_DistributionItem> _buildKvDistributionItems(
    List<KV> data,
    bool privacy, {
    String Function(num value)? valueFormatter,
    int colorOffset = 0,
  }) {
    final sorted = data.where((e) => e.value > 0).toList()..sort((a, b) => b.value.compareTo(a.value));
    return [
      for (var i = 0; i < sorted.length; i++)
        _DistributionItem(
          name: _mask(sorted[i].name, privacy),
          value: sorted[i].value,
          color: _phoneTreemapChartColor(i + colorOffset),
          valueText: valueFormatter?.call(sorted[i].value) ?? '${_formatCount(sorted[i].value)}',
        ),
    ];
  }

  Widget _buildDistributionDonut(
    List<_DistributionItem> items,
    num total, {
    String centerLabel = '总上传',
    String Function(num value) totalFormatter = formatBytes,
  }) {
    final chartData = items.map((item) {
      final pct = total <= 0 ? 0.0 : item.value / total * 100;
      return _PieData(
        name: item.name,
        value: item.value.toDouble(),
        tooltip:
            item.tooltip ??
            _buildDistributionTooltip(item.name, item.value, total, totalFormatter, valueText: item.valueText),
        color: item.color,
      );
    }).toList();
    return Stack(
      alignment: Alignment.center,
      children: [
        Listener(
          onPointerDown: _rememberDashboardTooltipPosition,
          child: SfCircularChart(
            margin: EdgeInsets.zero,
            tooltipBehavior: TooltipBehavior(
              enable: true,
              activationMode: ActivationMode.singleTap,
              header: '',
              canShowMarker: false,
              builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) =>
                  _buildDashboardOverlayTooltip((data as _PieData).tooltip),
            ),
            series: <DoughnutSeries<_PieData, String>>[
              DoughnutSeries<_PieData, String>(
                animationDuration: _phoneChartAnimationDuration,
                dataSource: chartData,
                xValueMapper: (d, _) => d.name,
                yValueMapper: (d, _) => d.value,
                pointColorMapper: (d, _) => d.color,
                radius: '96%',
                innerRadius: '58%',
                cornerStyle: CornerStyle.bothFlat,
              ),
            ],
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 78,
              child: Text(
                centerLabel,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: shadcn.Theme.of(context).typography.xSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: shadcn.Theme.of(context).colorScheme.mutedForeground,
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 82,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  totalFormatter(total),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: _phonePrimaryTextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _buildDistributionTooltip(
    String title,
    num value,
    num total,
    String Function(num value) formatter, {
    String? valueText,
    List<_DistributionItem> children = const [],
  }) {
    final pct = total <= 0 ? 0.0 : value / total * 100;
    final sortedChildren = [...children]..sort((a, b) => b.value.compareTo(a.value));
    return [
      title,
      '数值\t${valueText ?? formatter(value)}',
      '占比\t${pct.toStringAsFixed(1)}%',
      ...sortedChildren.map((item) => '${item.name}\t${item.valueText ?? formatter(item.value)}'),
    ].join('\n');
  }

  Widget _buildDistributionListRow(_DistributionItem item, num total) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final pct = total <= 0 ? 0.0 : item.value / total * 100;
    final valueText = item.valueText ?? formatBytes(item.value);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          _DashboardIconTooltip(
            message: item.tooltip ?? '${item.name}\n数值\t$valueText\n占比\t${pct.toStringAsFixed(1)}%',
            child: SizedBox(
              width: 9,
              height: 9,
              child: shadcn.Card(
                padding: EdgeInsets.zero,
                filled: true,
                fillColor: item.color,
                borderColor: item.color,
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _phonePrimaryTextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            valueText,
            style: shadcn.Theme.of(
              context,
            ).typography.xSmall.copyWith(fontWeight: FontWeight.w700, color: cs.mutedForeground),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 42,
            child: Text(
              '${pct.toStringAsFixed(1)}%',
              textAlign: TextAlign.right,
              style: shadcn.Theme.of(
                context,
              ).typography.xSmall.copyWith(fontWeight: FontWeight.w700, color: cs.mutedForeground),
            ),
          ),
        ],
      ),
    );
  }
}
