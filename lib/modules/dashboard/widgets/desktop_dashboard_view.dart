part of '../dashboard_page.dart';

extension _DesktopDashboardView on _DashboardPageState {
  // ———————————————— 桌面布局 ————————————————

  Widget _buildDesktopLayout(DashboardData data, bool privacy, DataCacheInfo cacheInfo, int refreshSerial) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = 8.0;

        return EasyRefresh(
          key: ValueKey('tablet-dashboard-$refreshSerial'),
          controller: _refreshController,
          onRefresh: _onRefresh,
          header: appRefreshHeader(context),
          child: CustomScrollView(
            controller: _scrollController, // ← 加这个
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.all(padding),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildServerBar(privacy),
                    CacheStatusBanner(info: cacheInfo, margin: const EdgeInsets.only(top: 8)),
                    const SizedBox(height: 12),
                    ..._buildPolishedDesktopDashboardChildren(data, privacy),
                    SizedBox(height: _DashboardPageState._bottomSafeGap + ShellBottomSpacing.value(context)),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildPolishedDesktopDashboardChildren(DashboardData data, bool privacy) {
    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 7, child: _buildPhoneOverviewCard(data)),
          const SizedBox(width: 12),
          Expanded(flex: 5, child: _buildPhoneQuickActionsCard()),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildPhoneTrendCard(data, privacy)),
          const SizedBox(width: 12),
          Expanded(child: _buildPhoneUploadDistributionCard(data, privacy)),
        ],
      ),
      const SizedBox(height: 12),
      _buildDesktopFocusCard(data, privacy),
      const SizedBox(height: 12),
      _buildStatusChart('站点状态', data.statusList, privacy),
    ];
  }

  Widget _buildDesktopFocusCard(DashboardData data, bool privacy) {
    final sorted = data.seedDataList.where((e) => e.value > 0).toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(6).toList();
    final total = sorted.fold<num>(0, (sum, item) => sum + item.value);
    return _buildBeautyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('做种焦点', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          if (top.isEmpty)
            _buildPanelEmpty()
          else
            ...top.map((item) {
              final ratio = total <= 0 ? 0.0 : item.value / total;
              return _buildRankBarRow(
                0,
                _mask(item.name, privacy),
                formatBytes(item.value),
                ratio,
                const Color(0xFF6366F1),
              );
            }),
        ],
      ),
    );
  }

  List<Widget> _buildPolishedDashboardChildren(DashboardData data, bool privacy, List<String> chartIds) {
    return [
      _buildPolishedHero(data, privacy),
      const SizedBox(height: 10),
      _buildPolishedActionRow(),
      const SizedBox(height: 10),
      _buildPolishedMetricGrid(data),
      const SizedBox(height: 12),
      _buildPolishedChartSection(data, privacy, chartIds),
    ];
  }

  Widget _buildPolishedHero(DashboardData data, bool privacy) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final accountAge = _showAccountAgeWeeks
        ? _formatAccountAgeWeeks(data.earliestSite?.timeJoin)
        : _formatAccountAgeYears(data.earliestSite?.timeJoin);
    final designation = _getDesignation(data.siteCount);
    final lastRefresh = formatDateStringToMinute(data.updatedAt, empty: '-');

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 620 ? 2 : 4;
        const spacing = 12.0;
        final metricWidth = (constraints.maxWidth - 32 - spacing * (columns - 1)) / columns;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.background.withValues(alpha: 0.96),
            borderRadius: shadcn.Theme.of(context).borderRadiusLg,
            border: Border.all(color: cs.border.withValues(alpha: 0.62)),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF3B82F6).withValues(alpha: 0.12),
                const Color(0xFFEEF6FF).withValues(alpha: 0.10),
                cs.background,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 6),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '数据总览',
                      style: shadcn.Theme.of(context).typography.large.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                    decoration: BoxDecoration(
                      color: cs.background.withValues(alpha: 0.72),
                      borderRadius: shadcn.Theme.of(context).borderRadiusXl,
                      border: Border.all(color: cs.border.withValues(alpha: 0.7)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(shadcn.LucideIcons.refreshCw, size: 12, color: cs.primary),
                        const SizedBox(width: 4),
                        Text(
                          '更新于 $lastRefresh',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.mutedForeground),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: spacing,
                runSpacing: 12,
                children: [
                  _buildOverviewMetric(
                    '总上传',
                    formatBytes(data.totalUploaded),
                    '今日 +${formatBytes(data.todayUploadIncrement)}',
                    shadcn.LucideIcons.arrowUp,
                    const Color(0xFF10B981),
                    metricWidth,
                  ),
                  _buildOverviewMetric(
                    '总下载',
                    formatBytes(data.totalDownloaded),
                    '今日 +${formatBytes(data.todayDownloadIncrement)}',
                    shadcn.LucideIcons.arrowDown,
                    const Color(0xFFEF4444),
                    metricWidth,
                  ),
                  _buildOverviewMetric(
                    'P龄',
                    accountAge,
                    designation,
                    shadcn.LucideIcons.calendar,
                    const Color(0xFF3B82F6),
                    metricWidth,
                    onTap: () => setState(() => _showAccountAgeWeeks = !_showAccountAgeWeeks),
                  ),
                  _buildOverviewMetric(
                    '站点数',
                    '${data.siteCount.toInt()}',
                    '做种 ${data.totalSeeding}',
                    shadcn.LucideIcons.globe,
                    const Color(0xFF8B5CF6),
                    metricWidth,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewMetric(
    String label,
    String value,
    String caption,
    IconData icon,
    Color color,
    double width, {
    VoidCallback? onTap,
  }) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                        child: Icon(icon, size: 15, color: color),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: cs.mutedForeground),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolishedActionRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 620 ? 2 : (constraints.maxWidth < 980 ? 4 : 4);
        const spacing = 10.0;
        final itemWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            _buildPolishedActionTile(
              '刷新任务',
              _isRefreshingSiteData ? '执行中' : '一键刷新所有',
              shadcn.LucideIcons.refreshCw,
              const Color(0xFF06B6D4),
              itemWidth,
              onTap: _hasRunningSummaryAction ? null : _refreshSiteData,
              loading: _isRefreshingSiteData,
            ),
            _buildPolishedActionTile(
              '重新拉取',
              _isRefreshingDashboardData ? '刷新中' : '更新站点数据',
              shadcn.LucideIcons.rotateCw,
              const Color(0xFF3B82F6),
              itemWidth,
              onTap: _hasRunningSummaryAction ? null : _refreshDashboardData,
              loading: _isRefreshingDashboardData,
            ),
            _buildPolishedActionTile(
              '站点签到',
              _isSigningInSites ? '执行中' : '领取每日奖励',
              shadcn.LucideIcons.calendarCheck,
              const Color(0xFFF59E0B),
              itemWidth,
              onTap: _hasRunningSummaryAction ? null : _signInSites,
              loading: _isSigningInSites,
            ),
            _buildPolishedActionTile(
              '展示设置',
              '调整数据看板',
              shadcn.LucideIcons.slidersHorizontal,
              const Color(0xFF10B981),
              itemWidth,
              onTap: () => _showChartSettings(context),
              loading: false,
            ),
          ],
        );
      },
    );
  }

  Widget _buildPolishedActionTile(
    String label,
    String value,
    IconData icon,
    Color color,
    double width, {
    VoidCallback? onTap,
    required bool loading,
  }) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final disabled = onTap == null && !loading;

    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 61,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: disabled ? 0.04 : 0.08),
            borderRadius: shadcn.Theme.of(context).borderRadiusMd,
            border: Border.all(color: color.withValues(alpha: disabled ? 0.10 : 0.18)),
          ),
          child: Row(
            children: [
              loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator())
                  : Icon(icon, size: 17, color: disabled ? color.withValues(alpha: 0.45) : color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: cs.mutedForeground),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: disabled ? cs.foreground.withValues(alpha: 0.45) : cs.foreground,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                shadcn.LucideIcons.chevronRight,
                size: 14,
                color: cs.mutedForeground.withValues(alpha: disabled ? 0.25 : 0.55),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolishedMetricGrid(DashboardData data) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final accountAge = _showAccountAgeWeeks
        ? _formatAccountAgeWeeks(data.earliestSite?.timeJoin)
        : _formatAccountAgeYears(data.earliestSite?.timeJoin);
    final items = [
      _StatItem('做种数', '${data.totalSeeding}', shadcn.LucideIcons.users, const Color(0xFF10B981)),
      _StatItem('下载数', '${data.totalLeeching}', shadcn.LucideIcons.arrowDown, const Color(0xFF3B82F6)),
      _StatItem('做种量', formatBytes(data.totalSeedVol), shadcn.LucideIcons.database, const Color(0xFF6366F1)),
      _StatItem('发种数', _formatCount(data.totalPublished), shadcn.LucideIcons.star, const Color(0xFFF59E0B)),
      _StatItem('站点数', '${data.siteCount.toInt()}', shadcn.LucideIcons.globe, const Color(0xFF8B5CF6)),
      _StatItem('今日上传', formatBytes(data.todayUploadIncrement), shadcn.LucideIcons.arrowUp, const Color(0xFF10B981)),
      _StatItem(
        'P龄',
        accountAge,
        shadcn.LucideIcons.calendar,
        const Color(0xFF14B8A6),
        onTap: () => setState(() => _showAccountAgeWeeks = !_showAccountAgeWeeks),
      ),
      _StatItem(
        '最后刷新',
        formatDateStringToMinute(data.updatedAt, empty: '-'),
        shadcn.LucideIcons.clock,
        const Color(0xFF64748B),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: shadcn.Theme.of(context).borderRadiusMd,
        border: Border.all(color: cs.border.withValues(alpha: 0.76)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '整体数据',
                  style: shadcn.Theme.of(context).typography.large.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              Icon(shadcn.LucideIcons.chevronRight, size: 17, color: cs.mutedForeground.withValues(alpha: 0.58)),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth < 640 ? 2 : 4;
              const spacing = 8.0;
              final itemWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: items
                    .map((item) => SizedBox(width: itemWidth, child: _buildPolishedMetricCard(item)))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPolishedMetricCard(_StatItem item) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: cs.mutedForeground.withValues(alpha: 0.025),
          borderRadius: shadcn.Theme.of(context).borderRadiusMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(item.icon, size: 14, color: item.color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: cs.mutedForeground),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              item.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, height: 1.05),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolishedChartSection(DashboardData data, bool privacy, List<String> chartIds) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(shadcn.LucideIcons.layoutDashboard, size: 16, color: cs.primary),
            const SizedBox(width: 6),
            Text('数据看板', style: shadcn.Theme.of(context).typography.large.copyWith(fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 10.0;
            final columns = constraints.maxWidth < 760 ? 1 : (constraints.maxWidth < 1320 ? 2 : 3);
            final itemWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;

            return Wrap(
              alignment: WrapAlignment.start,
              spacing: spacing,
              runSpacing: spacing,
              children: [
                SizedBox(width: itemWidth, child: _buildTrafficBalancePanel(data)),
                SizedBox(width: itemWidth, child: _buildTopSitePanel(data, privacy)),
                SizedBox(width: itemWidth, child: _buildTodayIncrementPanel(data, privacy)),
                SizedBox(width: itemWidth, child: _buildMonthlyTrendPanel(data)),
                SizedBox(
                  width: itemWidth,
                  child: _buildDistributionPanel('账号分布', shadcn.LucideIcons.users, const Color(0xFF8B5CF6), [
                    _DistributionGroup('邮箱', data.emailCount),
                    _DistributionGroup('用户名', data.usernameCount),
                  ], privacy),
                ),
                SizedBox(width: itemWidth, child: _buildSeedPanel(data, privacy)),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildInsightPanel({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
    String? subtitle,
  }) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 260),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: shadcn.Theme.of(context).borderRadiusMd,
        border: Border.all(color: cs.border.withValues(alpha: 0.76)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.11),
                  borderRadius: shadcn.Theme.of(context).borderRadiusSm,
                ),
                child: Icon(icon, size: 15, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: cs.mutedForeground),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildTrafficBalancePanel(DashboardData data) {
    final uploaded = data.totalUploaded.toDouble();
    final downloaded = data.totalDownloaded.toDouble();
    final total = uploaded + downloaded;
    final uploadRatio = total <= 0 ? 0.0 : uploaded / total;
    final downloadRatio = total <= 0 ? 0.0 : downloaded / total;
    final ratioLabel = downloaded <= 0 ? '∞' : '${(uploaded / downloaded).toStringAsFixed(2)}x';

    return _buildInsightPanel(
      title: '流量结构',
      subtitle: '上传/下载比例 $ratioLabel',
      icon: shadcn.LucideIcons.arrowUpDown,
      color: const Color(0xFF10B981),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildLargeValueBlock('上传', formatBytes(data.totalUploaded), const Color(0xFF10B981))),
              const SizedBox(width: 10),
              Expanded(child: _buildLargeValueBlock('下载', formatBytes(data.totalDownloaded), const Color(0xFFEF4444))),
            ],
          ),
          const SizedBox(height: 14),
          _buildSplitBar([
            _RatioSegment(uploadRatio, const Color(0xFF10B981)),
            _RatioSegment(downloadRatio, const Color(0xFFEF4444)),
          ]),
          const SizedBox(height: 12),
          _buildTinyStatLine('做种体量', formatBytes(data.totalSeedVol)),
          _buildTinyStatLine('总发种', '${_formatCount(data.totalPublished)} 个'),
        ],
      ),
    );
  }

  Widget _buildLargeValueBlock(String label, String value, Color color) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: shadcn.Theme.of(context).borderRadiusMd,
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: cs.mutedForeground)),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitBar(List<_RatioSegment> segments) {
    return ClipRRect(
      borderRadius: shadcn.Theme.of(context).borderRadiusXl,
      child: SizedBox(
        height: 10,
        child: Row(
          children: segments.map((segment) {
            final flex = (segment.ratio * 1000).round().clamp(1, 1000).toInt();
            return Expanded(
              flex: flex,
              child: Container(color: segment.color),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTinyStatLine(String label, String value) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 12, color: cs.mutedForeground)),
          ),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildTopSitePanel(DashboardData data, bool privacy) {
    final sites = data.statusList.where((e) => e.value.uploaded > 0).toList()
      ..sort((a, b) => b.value.uploaded.compareTo(a.value.uploaded));
    final top = sites.take(6).toList();
    final maxUploaded = top.isEmpty ? 0 : top.first.value.uploaded;

    return _buildInsightPanel(
      title: '上传量分布',
      subtitle: '按累计上传排序',
      icon: shadcn.LucideIcons.award,
      color: const Color(0xFFF59E0B),
      child: top.isEmpty
          ? _buildPanelEmpty()
          : Column(
              children: [
                for (var i = 0; i < top.length; i++)
                  _buildRankBarRow(
                    i + 1,
                    _mask(top[i].name, privacy),
                    formatBytes(top[i].value.uploaded),
                    maxUploaded <= 0 ? 0 : top[i].value.uploaded / maxUploaded,
                    _colors[i % _colors.length],
                  ),
              ],
            ),
    );
  }

  Widget _buildRankBarRow(int rank, String name, String value, num ratio, Color color) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            children: [
              if (rank > 0)
                SizedBox(
                  width: 24,
                  child: Text(
                    '#$rank',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: cs.mutedForeground),
                  ),
                )
              else
                const SizedBox(width: 0),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: cs.mutedForeground),
              ),
            ],
          ),
          const SizedBox(height: 5),
          _buildProgressBar(ratio.toDouble(), color),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double ratio, Color color) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: shadcn.Theme.of(context).borderRadiusXl,
      child: Container(
        height: 6,
        color: cs.mutedForeground.withValues(alpha: 0.08),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: ratio.clamp(0.02, 1.0).toDouble(),
          child: Container(color: color),
        ),
      ),
    );
  }

  Widget _buildTodayIncrementPanel(DashboardData data, bool privacy) {
    final increments = <_NamedPair>[];
    for (final upload in data.uploadIncrementDataList) {
      KV? download;
      for (final item in data.downloadIncrementDataList) {
        if (item.name == upload.name) {
          download = item;
          break;
        }
      }
      increments.add(_NamedPair(upload.name, upload.value, download?.value ?? 0));
    }
    increments.sort((a, b) => (b.primary + b.secondary).compareTo(a.primary + a.secondary));
    final top = increments.take(5).toList();

    return _buildInsightPanel(
      title: '今日动量',
      subtitle: '上传与下载增量',
      icon: shadcn.LucideIcons.activity,
      color: const Color(0xFF06B6D4),
      child: top.isEmpty
          ? _buildPanelEmpty()
          : Column(
              children: top.map((item) {
                return _buildDualMetricRow(
                  _mask(item.name, privacy),
                  formatBytes(item.primary),
                  formatBytes(item.secondary),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildDualMetricRow(String name, String upload, String download) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: cs.mutedForeground.withValues(alpha: 0.035),
        borderRadius: shadcn.Theme.of(context).borderRadiusMd,
        border: Border.all(color: cs.border.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          _buildMiniPill(shadcn.LucideIcons.arrowUp, upload, const Color(0xFF10B981)),
          const SizedBox(width: 6),
          _buildMiniPill(shadcn.LucideIcons.arrowDown, download, const Color(0xFFEF4444)),
        ],
      ),
    );
  }

  Widget _buildMiniPill(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: shadcn.Theme.of(context).borderRadiusXl,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTrendPanel(DashboardData data) {
    final totals = <String, num>{};
    for (final site in data.uploadMonthIncrementDataList) {
      for (final record in site.value) {
        totals[record.createdAt] = (totals[record.createdAt] ?? 0) + record.uploaded;
      }
    }
    final entries = totals.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final visible = entries.length > 12 ? entries.sublist(entries.length - 12) : entries;
    final maxValue = visible.fold<num>(0, (max, e) => e.value > max ? e.value : max);

    return _buildInsightPanel(
      title: '月度趋势',
      subtitle: '最近 ${visible.length} 个月上传增量',
      icon: shadcn.LucideIcons.chartNoAxesCombined,
      color: const Color(0xFF3B82F6),
      child: visible.isEmpty
          ? _buildPanelEmpty()
          : SizedBox(
              height: 178,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: visible.map((entry) {
                  final ratio = maxValue <= 0 ? 0.0 : entry.value / maxValue;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: ratio.toDouble().clamp(0.04, 1.0).toDouble(),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3B82F6).withValues(alpha: 0.82),
                                    borderRadius: BorderRadius.vertical(top: shadcn.Theme.of(context).radiusSmRadius),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _formatMonth(entry.key),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 9, color: shadcn.Theme.of(context).colorScheme.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }

  Widget _buildDistributionPanel(
    String title,
    IconData icon,
    Color color,
    List<_DistributionGroup> groups,
    bool privacy,
  ) {
    return _buildInsightPanel(
      title: title,
      subtitle: '账号维度聚合',
      icon: icon,
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: groups.map((group) {
          final sorted = group.items.toList()..sort((a, b) => b.value.compareTo(a.value));
          final total = sorted.fold<num>(0, (sum, e) => sum + e.value);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTinyStatLine(group.label, '${_formatCount(total)} 个'),
                const SizedBox(height: 6),
                if (sorted.isEmpty)
                  _buildPanelEmpty(compact: true)
                else
                  ...sorted.take(4).map((item) {
                    final ratio = total <= 0 ? 0.0 : item.value / total;
                    return _buildRankBarRow(0, _mask(item.name, privacy), '${_formatCount(item.value)}', ratio, color);
                  }),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSeedPanel(DashboardData data, bool privacy) {
    final seeds = data.seedDataList.where((e) => e.value > 0).toList()..sort((a, b) => b.value.compareTo(a.value));
    final total = seeds.fold<num>(0, (sum, e) => sum + e.value);
    final top = seeds.take(6).toList();

    return _buildInsightPanel(
      title: '做种分布',
      subtitle: '总做种 ${formatBytes(total)}',
      icon: shadcn.LucideIcons.database,
      color: const Color(0xFF6366F1),
      child: top.isEmpty
          ? _buildPanelEmpty()
          : Column(
              children: top.map((item) {
                final ratio = total <= 0 ? 0.0 : item.value / total;
                return _buildRankBarRow(
                  0,
                  _mask(item.name, privacy),
                  formatBytes(item.value),
                  ratio,
                  const Color(0xFF6366F1),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildPanelEmpty({bool compact = false}) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return SizedBox(
      height: compact ? 38 : 160,
      child: Center(
        child: Text('暂无数据', style: TextStyle(fontSize: 12, color: cs.mutedForeground)),
      ),
    );
  }
}
