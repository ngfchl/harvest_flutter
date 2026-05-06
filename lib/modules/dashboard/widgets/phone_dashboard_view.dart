part of '../dashboard_page.dart';

extension _PhoneDashboardView on _DashboardPageState {
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

    final totals = {
      for (final date in dates) date: _TrendPoint(date, 0, 0),
    };
    final uploadDetails = {
      for (final date in dates) date: <MapEntry<String, num>>[],
    };
    final downloadDetails = {
      for (final date in dates) date: <MapEntry<String, num>>[],
    };

    for (final site in data.stackChartDataList) {
      for (final record in site.value) {
        final date = record.createdAt.trim();
        final current = totals[date];
        if (current == null) continue;
        totals[date] = _TrendPoint(
          date,
          current.upload + record.uploaded,
          current.download + record.downloaded,
        );
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
      return _TrendPoint(
        date,
        point.upload,
        point.download,
        uploadDetails: uploads,
        downloadDetails: downloads,
      );
    }).toList();
  }

  TextStyle _phoneTitleStyle(double fontSize) {
    final cs = FTheme.of(context).colors;
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      color: cs.foreground,
    );
  }

  TextStyle _phonePrimaryTextStyle({
    required double fontSize,
    required FontWeight fontWeight,
    double? height,
  }) {
    final cs = FTheme.of(context).colors;
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: cs.foreground,
      height: height,
    );
  }

  // ———————————————— 手机布局 ————————————————

  Widget _buildPhoneLayout(
    DashboardData data,
    bool privacy,
  ) {
    final children = <Widget>[
      _buildServerBar(privacy),
      const SizedBox(height: 12),
      ..._buildPolishedPhoneDashboardChildren(data, privacy),
      SizedBox(
        height: _DashboardPageState._bottomSafeGap +
            ShellBottomSpacing.value(context),
      ),
    ];

    final scrollView = EasyRefresh(
      controller: _refreshController,
      onRefresh: _onRefresh,
      header: appRefreshHeader(context),
      child: CustomScrollView(
        controller: _scrollController, // ← 加这个
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            sliver: SliverList(
              delegate: SliverChildListDelegate(children),
            ),
          ),
        ],
      ),
    );

    return scrollView;
  }

  Widget _buildPhonePageHeader(DashboardData data, bool privacy) {
    final cs = FTheme.of(context).colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 6, 2, 4),
      child: SizedBox(
        height: 104,
        child: Stack(
          children: [
            Positioned(
              right: 92,
              top: 4,
              child: Container(
                foregroundDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.primary.withValues(alpha: 0.02),
                ),
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.primary.withValues(alpha: 0.12),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.08),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPolishedPhoneDashboardChildren(
    DashboardData data,
    bool privacy,
  ) {
    return [
      _buildPhoneDesignationPanel(data),
      const SizedBox(height: 12),
      _buildPhoneOverviewCard(data),
      const SizedBox(height: 12),
      _buildPhoneQuickActionsCard(),
      const SizedBox(height: 12),
      _buildPhoneTrendCard(data, privacy),
      const SizedBox(height: 12),
      _buildStatusChart('站点状态', data.statusList, privacy),
      const SizedBox(height: 12),
      _buildPhoneUploadDistributionCard(data, privacy),
      const SizedBox(height: 12),
      _buildPhoneUserDistributionCard(data, privacy),
      const SizedBox(height: 12),
      _buildPhoneTodayIncrementCard(data, privacy),
      const SizedBox(height: 12),
      _buildPhoneSeedDistributionCard(data, privacy),
      const SizedBox(height: 12),
      _buildPhoneMonthlyMetricCard(
        title: '月度上传',
        data: data.uploadMonthIncrementDataList,
        getValue: (record) => record.uploaded,
        formatValue: formatBytes,
        color: const Color(0xFF10B981),
        privacy: privacy,
      ),
      const SizedBox(height: 12),
      _buildPhoneMonthlyMetricCard(
        title: '月度下载',
        data: data.uploadMonthIncrementDataList,
        getValue: (record) => record.downloaded,
        formatValue: formatBytes,
        color: const Color(0xFFEF4444),
        privacy: privacy,
      ),
      const SizedBox(height: 12),
      _buildPhoneMonthlyMetricCard(
        title: '月度发种',
        data: data.uploadMonthIncrementDataList,
        getValue: (record) => record.published,
        formatValue: (value) => '${_formatCount(value)} 个',
        color: const Color(0xFFF59E0B),
        privacy: privacy,
      ),
    ];
  }

  Widget _buildPhoneDesignationPanel(DashboardData data) {
    final cs = FTheme.of(context).colors;
    const red = Color(0xFFE11D48);
    final siteCount = data.siteCount.toInt();
    final designation = _getDesignation(data.siteCount);
    final progress = _phoneDesignationProgress(siteCount);
    final subtitle = progress.completed
        ? '$siteCount 个站点接入 · 最高等级'
        : '$siteCount 个站点接入 · 下级 ${progress.nextTitle} 还差 ${progress.remaining} 站';

    return Container(
      constraints: const BoxConstraints(minHeight: 128),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
                    strutStyle: const StrutStyle(
                      forceStrutHeight: true,
                      height: 1.0,
                    ),
                    style: _phonePrimaryTextStyle(
                      fontSize: FTheme.of(context).typography.lg.fontSize ?? 17,
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
                      style: TextStyle(
                        color: cs.mutedForeground,
                        fontSize: 11,
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
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: red.withValues(alpha: 0.28)),
                  ),
                  child: const Icon(FIcons.award, size: 30, color: red),
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

  Widget _buildBeautyCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    final cs = FTheme.of(context).colors;
    return Container(
      width: double.infinity,
      padding: padding,
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
      child: child,
    );
  }

  Widget _buildPhoneOverviewCard(DashboardData data) {
    final cs = FTheme.of(context).colors;
    final accountAge = _showAccountAgeWeeks
        ? _formatAccountAgeWeeks(data.earliestSite?.timeJoin)
        : _formatAccountAgeYears(data.earliestSite?.timeJoin);
    final lastRefresh = formatDateStringToMinute(data.updatedAt, empty: '-');
    final overallItems = [
      _StatItem('做种数', '${data.totalSeeding}', FIcons.users, const Color(0xFF10B981)),
      _StatItem('下载数', '${data.totalLeeching}', FIcons.download, const Color(0xFF2563EB)),
      _StatItem('做种量', formatBytes(data.totalSeedVol), FIcons.database, const Color(0xFF8B5CF6)),
      _StatItem('发种数', _formatCount(data.totalPublished), FIcons.star, const Color(0xFFF59E0B)),
    ];

    return _buildBeautyCard(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '数据总览',
                  style: _phoneTitleStyle(17),
                ),
              ),
              Text(
                '更新于 $lastRefresh',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: cs.mutedForeground,
                ),
              ),
              const SizedBox(width: 8),
              Icon(FIcons.refreshCw, size: 16, color: cs.primary),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth < 360 ? 2 : 4;
              const spacing = 10.0;
              final itemWidth =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: 10,
                children: [
                  _buildOverviewStatTile(
                    width: itemWidth,
                    label: '总上传',
                    value: formatBytes(data.totalUploaded),
                    caption: '较昨日 +${formatBytes(data.todayUploadIncrement)}',
                    icon: FIcons.arrowUp,
                    color: const Color(0xFF10B981),
                  ),
                  _buildOverviewStatTile(
                    width: itemWidth,
                    label: '总下载',
                    value: formatBytes(data.totalDownloaded),
                    caption: '较昨日 +${formatBytes(data.todayDownloadIncrement)}',
                    icon: FIcons.arrowDown,
                    color: const Color(0xFFEF4444),
                  ),
                  _buildOverviewStatTile(
                    width: itemWidth,
                    label: 'P龄',
                    value: accountAge,
                    caption: _showAccountAgeWeeks ? '按周显示' : '按年显示',
                    icon: FIcons.calendar,
                    color: const Color(0xFF2563EB),
                    tooltip: 'P龄\n当前：$accountAge\n点击切换年/周显示',
                    onTap: () => setState(
                      () => _showAccountAgeWeeks = !_showAccountAgeWeeks,
                    ),
                  ),
                  _buildOverviewStatTile(
                    width: itemWidth,
                    label: '站点数',
                    value: '${data.siteCount.toInt()}',
                    caption: '在线 ${data.statusList.length}',
                    icon: FIcons.globe,
                    color: const Color(0xFF8B5CF6),
                    tooltip:
                        '站点数\n总计：${data.siteCount.toInt()} 个\n当前列表：${data.statusList.length} 个',
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
    final cs = FTheme.of(context).colors;
    return SizedBox(
      width: width,
      child: Tooltip(
        message: tooltip ?? '$label\n$value\n$caption',
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 89,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.055),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.10)),
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
                        color: color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 14, color: color),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _phonePrimaryTextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: color,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: cs.mutedForeground,
                  ),
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
            '刷新任务',
            '一键刷新所有',
            FIcons.refreshCw,
            const Color(0xFF06B6D4),
            _hasRunningSummaryAction ? null : _refreshSiteData,
            _isRefreshingSiteData,
          ),
          _buildActionShortcut(
            '重新拉取',
            '更新站点数据',
            FIcons.rotateCw,
            const Color(0xFF2563EB),
            _hasRunningSummaryAction ? null : _refreshDashboardData,
            _isRefreshingDashboardData,
          ),
          _buildActionShortcut(
            '签到任务',
            '领取每日奖励',
            FIcons.calendarCheck,
            const Color(0xFFF59E0B),
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
    final cs = FTheme.of(context).colors;
    return Expanded(
      child: Tooltip(
        message: '$title\n$subtitle',
        child: GestureDetector(
          onTap: onTap,
          child: SizedBox(
            height: 102,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: FProgress.circularIcon(),
                        )
                      : Icon(icon, size: 27, color: color),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _phonePrimaryTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: cs.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneTrendCard(DashboardData data, bool privacy) {
    final trendPoints = _buildPhoneTrendPoints(data, privacy);
    final uploadTotal = trendPoints.fold<num>(
      0,
      (sum, point) => sum + point.upload,
    );
    final downloadTotal = trendPoints.fold<num>(
      0,
      (sum, point) => sum + point.download,
    );

    return _buildBeautyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '上传 / 下载趋势',
                  style: _phoneTitleStyle(17),
                ),
              ),
              _buildRangeChip('本周', _phoneTrendDays == 7, () => _setPhoneTrendDays(7)),
              _buildRangeChip('本月', _phoneTrendDays == 30, () => _setPhoneTrendDays(30)),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildTrendHalf(
                  '上传量',
                  formatBytes(uploadTotal),
                  FIcons.arrowUp,
                  const Color(0xFF10B981),
                  trendPoints,
                  (point) => point.upload,
                  (point) => point.uploadDetails,
                  '上传',
                ),
              ),
              Container(
                width: 1,
                height: 116,
                color: FTheme.of(context).colors.border.withValues(alpha: 0.55),
              ),
              Expanded(
                child: _buildTrendHalf(
                  '下载量',
                  formatBytes(downloadTotal),
                  FIcons.arrowDown,
                  const Color(0xFFEF4444),
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

  Widget _buildRangeChip(String label, bool selected, VoidCallback onTap) {
    final cs = FTheme.of(context).colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 4),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.mutedForeground.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: selected ? cs.primaryForeground : cs.mutedForeground,
          ),
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
    final cs = FTheme.of(context).colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: cs.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _phoneTitleStyle(19),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 58,
            child: _buildSparkBars(points, color, valueOf, detailsOf, tooltipLabel),
          ),
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
    final maxValue = points.fold<num>(
      0,
      (max, point) => valueOf(point) > max ? valueOf(point) : max,
    );
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
                child: Container(
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.72),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
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

  String _buildTrendTooltipText(
    _TrendPoint point,
    num value,
    List<MapEntry<String, num>> details,
    String label,
  ) {
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
          color: _DashboardPageState._colors[
              top.length % _DashboardPageState._colors.length],
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
              Expanded(
                child: Text(
                  '上传量分布',
                  style: _phoneTitleStyle(17),
                ),
              ),
              Icon(
                FIcons.chevronRight,
                size: 18,
                color: FTheme.of(context).colors.mutedForeground,
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
                  child: Column(
                    children: displayItems
                        .map((item) => _buildDistributionListRow(item, total))
                        .toList(),
                  ),
                );
                if (stacked) {
                  return Column(
                    children: [
                      chart,
                      const SizedBox(height: 8),
                      ...displayItems.map(
                        (item) => _buildDistributionListRow(item, total),
                      ),
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
          Text(
            '用户信息分布',
            style: _phoneTitleStyle(17),
          ),
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
    final rangeLabel = _phoneTrendDays == 7 ? '本周' : '本月';
    return _buildBeautyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$rangeLabel增量排行',
                  style: _phonePrimaryTextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '近$_phoneTrendDays天',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: FTheme.of(context).colors.mutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: chartItems.length <= 4 ? 214 : 276,
            child: chartItems.isEmpty
                ? this._buildPanelEmpty()
                : _buildIncrementBarChart(chartItems),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneSeedDistributionCard(DashboardData data, bool privacy) {
    final items = _buildKvDistributionItems(
      data.seedDataList,
      privacy,
      valueFormatter: formatBytes,
    );
    return _buildPhoneGenericDistributionCard(
      title: '做种分布',
      centerLabel: '总做种',
      items: items,
      totalFormatter: formatBytes,
    );
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
          siteDetails
              .putIfAbsent(record.createdAt, () => [])
              .add(MapEntry(_mask(site.name, privacy), value));
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
      return _MonthlyChartItem(
        _formatMonth(entry.key),
        entry.value,
        formatValue(entry.value),
        tooltipLines.join('\n'),
      );
    }).toList();
    return _buildBeautyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: _phoneTitleStyle(17),
                ),
              ),
              Text(
                formatValue(total),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: FTheme.of(context).colors.mutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 176,
            child: _buildMonthlyColumnChart(chartItems, color, formatValue),
          ),
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
    final cs = FTheme.of(context).colors;

    return Listener(
      onPointerDown: _rememberDashboardTooltipPosition,
      child: SfCartesianChart(
        margin: EdgeInsets.zero,
        plotAreaBorderWidth: 0,
        primaryXAxis: CategoryAxis(
          labelStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: cs.mutedForeground,
          ),
          axisLine: const AxisLine(width: 0),
          majorGridLines: const MajorGridLines(width: 0),
          majorTickLines: const MajorTickLines(size: 0),
          labelIntersectAction: AxisLabelIntersectAction.wrap,
        ),
        primaryYAxis: NumericAxis(
          labelStyle: TextStyle(fontSize: 10, color: cs.mutedForeground),
          axisLine: const AxisLine(width: 0),
          majorTickLines: const MajorTickLines(size: 0),
          majorGridLines: MajorGridLines(
            width: 0.5,
            color: cs.border.withValues(alpha: 0.45),
          ),
          axisLabelFormatter: (details) => ChartAxisLabel(
            formatValue(details.value),
            details.textStyle,
          ),
        ),
        series: <CartesianSeries<_MonthlyChartItem, String>>[
          ColumnSeries<_MonthlyChartItem, String>(
            dataSource: chartItems,
            xValueMapper: (item, _) => item.label,
            yValueMapper: (item, _) => item.value,
            pointColorMapper: (_, index) =>
                color.withValues(alpha: index.isEven ? 0.86 : 0.62),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
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
          builder:
              (
                dynamic data,
                dynamic point,
                dynamic series,
                int pointIndex,
                int seriesIndex,
              ) => _buildDashboardOverlayTooltip(
                (data as _MonthlyChartItem).tooltip,
              ),
        ),
      ),
    );
  }

  Widget _buildPhoneGenericDistributionCard({
    required String title,
    required String centerLabel,
    required List<_DistributionItem> items,
    required String Function(num value) totalFormatter,
  }) {
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
          color: _DashboardPageState._colors[
              top.length % _DashboardPageState._colors.length],
          valueText: totalFormatter(otherValue),
          tooltip: _buildDistributionTooltip(
            '其他 ${items.length - top.length} 项',
            otherValue,
            total,
            totalFormatter,
            children: otherItems,
          ),
        ),
    ];
    return _buildBeautyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: _phoneTitleStyle(17),
          ),
          const SizedBox(height: 16),
          if (displayItems.isEmpty)
            this._buildPanelEmpty()
          else ...[
            SizedBox(
              height: 204,
              child: _buildDistributionDonut(
                displayItems,
                total,
                centerLabel: centerLabel,
                totalFormatter: totalFormatter,
              ),
            ),
            const SizedBox(height: 8),
            ...displayItems.map((item) => _buildDistributionListRow(item, total)),
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
          color: _DashboardPageState._colors[
              top.length % _DashboardPageState._colors.length],
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
        Text(
          title,
          style: _phoneTitleStyle(14),
        ),
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
                children: displayItems
                    .map((item) => _buildDistributionListRow(item, total))
                    .toList(),
              );

              if (constraints.maxWidth < 300) {
                return Column(
                  children: [
                    chart,
                    const SizedBox(height: 6),
                    list,
                  ],
                );
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

  List<_IncrementChartItem> _buildIncrementChartItems(
    DashboardData data,
    bool privacy,
  ) {
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
    }).toList()
      ..sort((a, b) => (b.upload + b.download).compareTo(a.upload + a.download));
    return items.take(10).toList();
  }

  Widget _buildIncrementBarChart(List<_IncrementChartItem> items) {
    final cs = FTheme.of(context).colors;
    return Listener(
      onPointerDown: _rememberDashboardTooltipPosition,
      child: SfCartesianChart(
        margin: EdgeInsets.zero,
        plotAreaBorderWidth: 0,
        legend: Legend(
          isVisible: true,
          position: LegendPosition.bottom,
          overflowMode: LegendItemOverflowMode.wrap,
          textStyle: TextStyle(fontSize: 11, color: cs.mutedForeground),
        ),
        primaryXAxis: CategoryAxis(
          labelStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: cs.mutedForeground,
          ),
          axisLine: const AxisLine(width: 0),
          majorGridLines: const MajorGridLines(width: 0),
          majorTickLines: const MajorTickLines(size: 0),
          labelIntersectAction: AxisLabelIntersectAction.wrap,
        ),
        primaryYAxis: NumericAxis(
          labelStyle: TextStyle(fontSize: 10, color: cs.mutedForeground),
          axisLine: const AxisLine(width: 0),
          majorTickLines: const MajorTickLines(size: 0),
          majorGridLines: MajorGridLines(
            width: 0.5,
            color: cs.border.withValues(alpha: 0.5),
          ),
          axisLabelFormatter: (details) => ChartAxisLabel(
            formatYAxis(details.value),
            details.textStyle,
          ),
        ),
        series: <CartesianSeries<_IncrementChartItem, String>>[
          BarSeries<_IncrementChartItem, String>(
            dataSource: items,
            xValueMapper: (item, _) => item.name,
            yValueMapper: (item, _) => item.upload,
            name: '上传',
            color: const Color(0xFF10B981),
            borderRadius:
                const BorderRadius.horizontal(right: Radius.circular(5)),
            width: 0.62,
            spacing: 0.18,
          ),
          BarSeries<_IncrementChartItem, String>(
            dataSource: items,
            xValueMapper: (item, _) => item.name,
            yValueMapper: (item, _) => item.download,
            name: '下载',
            color: const Color(0xFFEF4444),
            borderRadius:
                const BorderRadius.horizontal(right: Radius.circular(5)),
            width: 0.62,
            spacing: 0.18,
          ),
        ],
        tooltipBehavior: TooltipBehavior(
          enable: true,
          activationMode: ActivationMode.singleTap,
          header: '',
          canShowMarker: false,
          builder:
              (
                dynamic data,
                dynamic point,
                dynamic series,
                int pointIndex,
                int seriesIndex,
              ) => _buildDashboardOverlayTooltip(
                '${(data as _IncrementChartItem).name}\n${(data as _IncrementChartItem).tooltip}',
              ),
        ),
      ),
    );
  }

  Widget _buildCompactDistributionBlock(
    String title,
    List<_DistributionItem> items,
  ) {
    final total = items.fold<num>(0, (sum, item) => sum + item.value);
    final top = items.take(4).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: _phoneTitleStyle(14),
              ),
            ),
            Text(
              '${_formatCount(total)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: FTheme.of(context).colors.mutedForeground,
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

  List<_DistributionItem> _buildUploadDistributionItems(
    DashboardData data,
    bool privacy,
  ) {
    final sorted = data.statusList.where((e) => e.value.uploaded > 0).toList()
      ..sort((a, b) => b.value.uploaded.compareTo(a.value.uploaded));
    return [
      for (var i = 0; i < sorted.length; i++)
        _DistributionItem(
          name: _mask(sorted[i].name, privacy),
          value: sorted[i].value.uploaded,
          color: _DashboardPageState._colors[i % _DashboardPageState._colors.length],
          valueText: formatBytes(sorted[i].value.uploaded),
        ),
    ];
  }

  List<_DistributionItem> _buildKvDistributionItems(
    List<KV> data,
    bool privacy, {
    String Function(num value)? valueFormatter,
  }) {
    final sorted = data.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [
      for (var i = 0; i < sorted.length; i++)
        _DistributionItem(
          name: _mask(sorted[i].name, privacy),
          value: sorted[i].value,
          color: _DashboardPageState._colors[i % _DashboardPageState._colors.length],
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
    final chartData = items
        .map(
          (item) {
            final pct = total <= 0 ? 0.0 : item.value / total * 100;
            return _PieData(
              name: item.name,
              value: item.value.toDouble(),
              tooltip: item.tooltip ??
                  _buildDistributionTooltip(
                    item.name,
                    item.value,
                    total,
                    totalFormatter,
                    valueText: item.valueText,
                  ),
              color: item.color,
            );
          },
        )
        .toList();
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
            Text(
              centerLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: FTheme.of(context).colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              totalFormatter(total),
              style: _phonePrimaryTextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
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
    final sortedChildren = [...children]
      ..sort((a, b) => b.value.compareTo(a.value));
    return [
      title,
      '数值\t${valueText ?? formatter(value)}',
      '占比\t${pct.toStringAsFixed(1)}%',
      ...sortedChildren.map(
        (item) => '${item.name}\t${item.valueText ?? formatter(item.value)}',
      ),
    ].join('\n');
  }

  Widget _buildDistributionListRow(_DistributionItem item, num total) {
    final cs = FTheme.of(context).colors;
    final pct = total <= 0 ? 0.0 : item.value / total * 100;
    final valueText = item.valueText ?? formatBytes(item.value);
    return Tooltip(
      message: item.tooltip ??
          '${item.name}\n数值\t$valueText\n占比\t${pct.toStringAsFixed(1)}%',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: item.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _phonePrimaryTextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              valueText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.mutedForeground,
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 42,
              child: Text(
                '${pct.toStringAsFixed(1)}%',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: cs.mutedForeground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


}
