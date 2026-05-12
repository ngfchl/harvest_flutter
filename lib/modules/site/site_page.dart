import 'package:easy_refresh/easy_refresh.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/storage/storage_keys.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/site/model/site_config.dart';
import 'package:harvest/modules/site/model/site_info.dart';
import 'package:harvest/widgets/app_menu.dart';
import 'package:harvest/widgets/app_sheet.dart';
import 'package:harvest/widgets/browser_page.dart';
import 'package:harvest/widgets/shad_text_field.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../widgets/cache_status_banner.dart';
import '../shell/provider/screenshot_provider.dart';
import '../shell/widgets/shell_scaffold.dart';
import 'provider/site_card_style_provider.dart';
import 'provider/site_filtered_provider.dart';
import 'provider/site_provider.dart';
import 'widgets/site_config_generator_dialog.dart';
import 'widgets/site_error_view.dart';
import 'widgets/site_filter_panel.dart';
import 'widgets/site_form_sheet.dart';
import 'widgets/site_list_view.dart';
import 'widgets/site_theme.dart';
import 'site_timeline_page.dart';

class SitePage extends ConsumerStatefulWidget {
  const SitePage({super.key});

  @override
  ConsumerState<SitePage> createState() => _SitePageState();
}

class _SitePageState extends ConsumerState<SitePage> {
  bool _showFilter = false;
  final _searchCtrl = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(activeScrollControllerProvider.notifier).state = _scrollController;
    });
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchTextChanged);
    _searchCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    ref.read(siteFilterStateProvider).setSiteNameQuery(_searchCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final sitesAsync = ref.watch(siteInfoListProvider);
    final filteredSites = ref.watch(filteredSiteListProvider);
    final filter = ref.watch(siteFilterStateProvider);
    final hasFilters = filter.hasActiveFilters;
    final totalCount = sitesAsync.valueOrNull?.length ?? 0;
    final mobile = context.isMobile;
    final cacheInfo = ref.watch(siteInfoCacheInfoProvider);

    final cs = shadcn.Theme.of(context).colorScheme;

    return Material(
      color: cs.background,
      child: Column(
        children: [
          // 筛选面板（桌面端展开时显示）
          if (!mobile && _showFilter) SiteFilterPanel(onClose: () => setState(() => _showFilter = false)),
          // 工具栏统一放顶部
          _buildToolbar(context, filteredSites.length, totalCount, hasFilters, mobile),
          CacheStatusBanner(info: cacheInfo, margin: EdgeInsets.fromLTRB(mobile ? 12 : 16, 0, mobile ? 12 : 16, 6)),
          Expanded(
            child: EasyRefresh(
              onRefresh: _refresh,
              header: appRefreshHeader(context),
              child: sitesAsync.when(
                loading: () => _buildLoading(context),
                error: (e, _) => SiteErrorView(error: e, onRetry: _refresh),
                data: (_) {
                  if (filteredSites.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(bottom: ShellBottomSpacing.value(context)),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                        Center(
                          child: Text(
                            hasFilters ? '没有符合筛选条件的站点' : '暂无站点数据',
                            style: shadcn.Theme.of(
                              context,
                            ).typography.small.copyWith(color: shadcn.Theme.of(context).colorScheme.mutedForeground),
                          ),
                        ),
                      ],
                    );
                  }
                  return SiteListView(sites: filteredSites, controller: _scrollController);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refresh() async {
    await ref.read(siteInfoListProvider.notifier).refresh();
  }

  Widget _buildLoading(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: ShellBottomSpacing.value(context)),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              shadcn.CircularProgressIndicator(strokeWidth: 2.4, color: cs.primary),
              const SizedBox(height: 16),
              Text('加载中...', style: TextStyle(color: cs.mutedForeground, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  // ── 工具栏 ──

  Widget _buildToolbar(BuildContext context, int current, int total, bool hasFilters, bool mobile) {
    final cs = shadcn.Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: mobile ? 8 : 5),
      margin: EdgeInsets.zero,
      height: mobile ? null : 48,
      decoration: BoxDecoration(
        color: mobile ? cs.background : null,
        border: mobile ? null : Border(bottom: BorderSide(color: cs.border.withValues(alpha: 0.4), width: 0.5)),
        boxShadow: mobile
            ? [BoxShadow(color: siteShadow(context, alpha: 0.06), blurRadius: 12, offset: const Offset(0, -2))]
            : null,
      ),
      child: Row(
        spacing: mobile ? 6 : 8,
        children: [
          _buildCounter(context, current, total, hasFilters),
          Expanded(child: _buildSearchField(context)),
          _filterButton(
            context,
            hasFilters,
            mobile ? () => _openFilterSheet(context) : () => setState(() => _showFilter = !_showFilter),
          ),
          _buildCardStyleMenu(context),
          _buildSiteCreateMenu(context),
        ],
      ),
    );
  }

  // ── 计数 ──

  Widget _buildCounter(BuildContext context, int current, int total, bool hasFilters) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$current',
            style: typo.small.copyWith(fontWeight: FontWeight.w700, color: hasFilters ? cs.primary : cs.foreground),
          ),
          TextSpan(
            text: ' / $total',
            style: typo.small.copyWith(color: cs.mutedForeground),
          ),
        ],
      ),
    );
  }

  // ── 搜索框 ──

  Widget _buildSearchField(BuildContext context, {double height = 38}) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return SizedBox(
      height: height,
      child: ShadTextField(
        controller: _searchCtrl,
        hintText: '搜索站点...',
        maxLines: 1,
        onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        features: [
          shadcn.InputFeature.clear(
            visibility: shadcn.InputFeatureVisibility.textNotEmpty,
            icon: Icon(shadcn.LucideIcons.x, size: 12, color: cs.mutedForeground),
          ),
        ],
      ),
    );
  }

  // ── 筛选按钮 ──

  Widget _filterButton(BuildContext context, bool hasFilters, VoidCallback onTap) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: 34,
        decoration: BoxDecoration(
          color: hasFilters ? cs.primary.withValues(alpha: 0.1) : cs.muted.withValues(alpha: 0.3),
          borderRadius: siteRadius(context, size: "xl"),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(shadcn.LucideIcons.slidersHorizontal, size: 14, color: hasFilters ? cs.primary : cs.mutedForeground),
            const SizedBox(width: 5),
            Text(
              '筛选',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: hasFilters ? cs.primary : cs.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardStyleMenu(BuildContext context) {
    return shadcn.OverlayManagerLayer(
      popoverHandler: const shadcn.PopoverOverlayHandler(),
      tooltipHandler: const shadcn.FixedTooltipOverlayHandler(),
      menuHandler: const shadcn.PopoverOverlayHandler(),
      child: Builder(
        builder: (menuContext) => shadcn.IconButton.ghost(
          onPressed: () => shadcn.showDropdown<void>(
            context: menuContext,
            alignment: Alignment.topCenter,
            offset: const Offset(0, 8),
            widthConstraint: shadcn.PopoverConstraint.intrinsic,
            heightConstraint: shadcn.PopoverConstraint.intrinsic,
            consumeOutsideTaps: false,
            builder: (dropdownContext) => Consumer(
              builder: (context, ref, _) {
                final current = ref.watch(siteCardStyleProvider);
                return AppDropdownMenu(
                  children: [
                    shadcn.MenuLabel(child: const Text('卡片样式')),
                    const shadcn.MenuDivider(),
                    _cardStyleTile(dropdownContext, SiteCardStyle.style1, current, '样式 1'),
                    _cardStyleTile(dropdownContext, SiteCardStyle.style2, current, '样式 2'),
                    _cardStyleTile(dropdownContext, SiteCardStyle.style3, current, '样式 3'),
                  ],
                );
              },
            ),
          ),
          icon: shadcn.Tooltip(
            tooltip: (_) => const Text('卡片样式'),
            child: const Icon(Icons.dashboard_customize_outlined, size: 18),
          ),
        ),
      ),
    );
  }

  shadcn.MenuButton _cardStyleTile(BuildContext context, SiteCardStyle style, SiteCardStyle current, String title) {
    final selected = style == current;
    final cs = siteColors(context);
    return shadcn.MenuButton(
      onPressed: (_) => setSiteCardStyle(ref, style),
      autoClose: true,
      child: SizedBox(
        width: 232,
        height: 62,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? cs.primary.withValues(alpha: 0.08) : siteTransparent(context),
            borderRadius: siteRadius(context, size: "md"),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                _cardStylePreview(context, style),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected ? cs.foreground : cs.mutedForeground,
                    ),
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 120),
                  opacity: selected ? 1 : 0,
                  child: Icon(shadcn.LucideIcons.check, size: 16, color: cs.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardStylePreview(BuildContext context, SiteCardStyle style) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return SizedBox(
      width: 76,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.brightness == Brightness.dark
              ? Color.alphaBlend(cs.muted.withValues(alpha: 0.10), cs.background)
              : siteColors(context).background,
          borderRadius: siteRadius(context, size: "md"),
          border: Border.all(color: cs.border, width: 0.8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: switch (style) {
            SiteCardStyle.style1 => _styleOnePreview(context),
            SiteCardStyle.style2 => _styleTwoPreview(context),
            SiteCardStyle.style3 => _styleThreePreview(context),
          },
        ),
      ),
    );
  }

  Widget _styleOnePreview(BuildContext context) {
    final cs = siteColors(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _previewDot(siteSuccess(context)),
            const SizedBox(width: 4),
            _previewLine(width: 28, color: cs.foreground, height: 5),
            const Spacer(),
            _previewLine(width: 14, color: cs.primary.withValues(alpha: 0.18), height: 6),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          height: 14,
          decoration: BoxDecoration(
            color: cs.muted.withValues(alpha: 0.65),
            borderRadius: siteRadius(context, size: "xs"),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _previewLine(width: 14, color: siteSuccess(context), height: 4),
              _previewLine(width: 14, color: siteDanger(context), height: 4),
              _previewLine(width: 14, color: cs.mutedForeground, height: 4),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            4,
            (_) => _previewLine(width: 12, color: cs.mutedForeground.withValues(alpha: 0.62), height: 4),
          ),
        ),
      ],
    );
  }

  Widget _styleTwoPreview(BuildContext context) {
    final cs = siteColors(context);
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(color: cs.foreground, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Expanded(child: _previewLine(width: 30, color: cs.foreground, height: 5)),
            _previewLine(width: 13, color: cs.mutedForeground.withValues(alpha: 0.62), height: 4),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Expanded(child: _previewLine(width: 18, color: siteSuccess(context), height: 6)),
            Expanded(child: _previewLine(width: 18, color: siteDanger(context), height: 6)),
            Expanded(child: _previewLine(width: 18, color: siteInfo(context), height: 6)),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(3, (_) => _previewLine(width: 15, color: cs.mutedForeground, height: 4)),
        ),
      ],
    );
  }

  Widget _styleThreePreview(BuildContext context) {
    final cs = siteColors(context);
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: siteSuccess(context),
                borderRadius: siteRadius(context, size: "xs"),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(child: _previewLine(width: 26, color: cs.foreground, height: 5)),
            _previewLine(width: 18, color: siteWarning(context, alpha: 0.18), height: 8),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: _previewBox(siteInfo(context, alpha: 0.16))),
            const SizedBox(width: 4),
            Expanded(child: _previewBox(siteSuccess(context, alpha: 0.14))),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: List.generate(
            4,
            (i) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == 3 ? 0 : 3),
                child: _previewBox(
                  [
                    siteSuccess(context, alpha: 0.14),
                    siteWarning(context, alpha: 0.16),
                    siteDanger(context, alpha: 0.12),
                    siteInfo(context, alpha: 0.14),
                  ][i],
                  height: 8,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _previewBox(Color color, {double height = 11}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: siteRadius(context, size: "xs"),
      ),
    );
  }

  Widget _previewDot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _previewLine({required double width, required double height, required Color color}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: siteRadius(context, size: "xl"),
        ),
      ),
    );
  }

  // ── 添加按钮 ──

  Widget _buildSiteCreateMenu(BuildContext context) {
    final anchorContext = context;
    return shadcn.OverlayManagerLayer(
      popoverHandler: const shadcn.PopoverOverlayHandler(),
      tooltipHandler: const shadcn.FixedTooltipOverlayHandler(),
      menuHandler: const shadcn.PopoverOverlayHandler(),
      child: Builder(
        builder: (menuContext) => shadcn.IconButton.ghost(
          onPressed: () => shadcn.showDropdown<void>(
            context: menuContext,
            builder: (_) => AppDropdownMenu(
              children: [
                _menuAction(
                  icon: shadcn.LucideIcons.plus,
                  label: '添加站点',
                  onPressed: () {
                    if (!anchorContext.mounted) return;
                    _openAdd(anchorContext);
                  },
                ),
                _menuAction(
                  icon: shadcn.LucideIcons.fileUp,
                  label: '上传配置',
                  onPressed: () {
                    if (!anchorContext.mounted) return;
                    _openImportTomlDialog(anchorContext);
                  },
                ),
                _menuAction(
                  icon: shadcn.LucideIcons.fileCode,
                  label: '生成配置',
                  onPressed: () {
                    if (!anchorContext.mounted) return;
                    showSiteConfigGenerator(anchorContext);
                  },
                ),
                _menuAction(
                  icon: shadcn.LucideIcons.gitBranchPlus,
                  label: '站点时间轴',
                  onPressed: () {
                    if (!anchorContext.mounted) return;
                    showSiteTimelineDialog(anchorContext);
                  },
                ),
              ],
            ),
          ),
          icon: shadcn.Tooltip(
            tooltip: (_) => const Text('站点操作'),
            child: const Icon(shadcn.LucideIcons.plus, size: 18),
          ),
        ),
      ),
    );
  }

  shadcn.MenuButton _menuAction({required IconData icon, required String label, required VoidCallback onPressed}) {
    return shadcn.MenuButton(leading: Icon(icon), onPressed: (_) => onPressed(), child: Text(label));
  }

  // ── 移动端筛选弹窗 ──

  void _openFilterSheet(BuildContext context) {
    showAppSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: siteTransparent(context),
      builder: (_) => _MobileFilterSheet(searchCtrl: _searchCtrl),
    );
  }

  // ── 添加站点 ──

  void _openAdd(BuildContext context) {
    showAddSiteSheet(context);
  }

  Future<void> _showSiteTimeline(BuildContext context) async {
    final websites = ref.read(websiteListProvider).valueOrNull ?? const <WebSite>[];
    final mySites = ref.read(siteInfoListProvider).valueOrNull ?? const <SiteInfo>[];
    if (websites.isEmpty) {
      Toast.warning('暂无站点配置');
      return;
    }

    final byName = <String, SiteInfo>{};
    for (final site in mySites) {
      byName[site.site.trim().toLowerCase()] = site;
    }

    final entries = websites.map((website) {
      final owned = byName[website.name.trim().toLowerCase()];
      return _SiteTimelineEntry(website: website, mySite: owned);
    }).toList();

    var ownership = _TimelineOwnership.all;
    var inviteFilter = _TimelineInviteFilter.all;
    var ascending = true;
    final savedShowDurationOnTitle = HiveManager.get<bool>(
      StorageKeys.siteTimelineTitleShowDuration,
    );
    var showDurationOnTitle = savedShowDurationOnTitle ?? false;
    final savedVisibleFields = HiveManager.get<Map>(StorageKeys.siteTimelineVisibleFields);
    final visibleFields = <String, bool>{
      'duration': false,
      'uploaded': false,
      'downloaded': false,
      'invitation': true,
      'username': false,
      'email': false,
      'uid': false,
    };
    if (savedVisibleFields != null) {
      for (final entry in savedVisibleFields.entries) {
        final key = entry.key.toString();
        if (visibleFields.containsKey(key)) {
          visibleFields[key] = entry.value == true;
        }
      }
    }

    await shadcn.showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          final cs = shadcn.Theme.of(dialogContext).colorScheme;
          final enabledOwnedEntries = <_SiteTimelineEntry>[];
          final disabledOwnedEntries = <_SiteTimelineEntry>[];
          final unownedEntries = <_SiteTimelineEntry>[];
          for (final entry in entries) {
            if (!entry.isOwned) {
              unownedEntries.add(entry);
            } else if (entry.isDisabled) {
              disabledOwnedEntries.add(entry);
            } else {
              enabledOwnedEntries.add(entry);
            }
          }

          bool matches(_SiteTimelineEntry entry) {
            if (ownership == _TimelineOwnership.ownedOnly && !entry.isOwned) return false;
            if (ownership == _TimelineOwnership.unownedOnly && entry.isOwned) return false;
            final invites = entry.invitationCount;
            if (inviteFilter == _TimelineInviteFilter.has && invites <= 0) return false;
            if (inviteFilter == _TimelineInviteFilter.none && invites > 0) return false;
            return true;
          }

          int sortByTime(_SiteTimelineEntry a, _SiteTimelineEntry b) {
            final at = a.registeredAt;
            final bt = b.registeredAt;
            if (at == null && bt == null) return a.displayName.compareTo(b.displayName);
            if (at == null) return 1;
            if (bt == null) return -1;
            final cmp = at.compareTo(bt);
            return ascending ? cmp : -cmp;
          }

          final filteredEnabledOwned = enabledOwnedEntries.where(matches).toList()
            ..sort(sortByTime);
          final filteredDisabledOwned = disabledOwnedEntries.where(matches).toList()
            ..sort(sortByTime);
          final filteredUnowned = unownedEntries.where(matches).toList()
            ..sort((a, b) => a.displayName.compareTo(b.displayName));
          final displayList = <_SiteTimelineEntry>[
            ...filteredEnabledOwned,
            ...filteredDisabledOwned,
            ...filteredUnowned,
          ];

          Widget openUnownedAction(_SiteTimelineEntry entry) {
            return shadcn.Button.ghost(
              onPressed: () async {
                final urls = entry.website.url.where((e) => e.trim().isNotEmpty).toList();
                if (urls.isEmpty) {
                  Toast.warning('该站点未配置可用 URL');
                  return;
                }
                if (urls.length == 1) {
                  if (!dialogContext.mounted) return;
                  Navigator.of(dialogContext).pop();
                  BrowserPage.open(
                    context,
                    url: urls.first,
                    title: entry.displayName,
                    siteId: entry.website.name,
                    website: entry.website,
                  );
                  return;
                }
                final selected = await shadcn.showDialog<String>(
                  context: dialogContext,
                  builder: (ctx) {
                    final cs = shadcn.Theme.of(ctx).colorScheme;
                    final typo = shadcn.Theme.of(ctx).typography;
                    return shadcn.AlertDialog(
                      title: const Text('选择站点地址'),
                      content: SizedBox(
                        width: 560,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 360),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (var i = 0; i < urls.length; i++) ...[
                                  GestureDetector(
                                    onTap: () => Navigator.of(ctx).pop(urls[i]),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                                      decoration: BoxDecoration(
                                        color: cs.muted.withValues(alpha: 0.16),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(shadcn.LucideIcons.globe, size: 15, color: cs.mutedForeground),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _timelineUrlHost(urls[i]),
                                                  style: typo.small.copyWith(
                                                    color: cs.foreground,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  urls[i],
                                                  style: typo.xSmall.copyWith(color: cs.mutedForeground),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(shadcn.LucideIcons.chevronRight, size: 15, color: cs.mutedForeground),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (i != urls.length - 1) const SizedBox(height: 6),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        shadcn.Button.outline(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('取消'),
                        ),
                      ],
                    );
                  },
                );
                if (selected == null || selected.isEmpty) return;
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                BrowserPage.open(
                  context,
                  url: selected,
                  title: entry.displayName,
                  siteId: entry.website.name,
                  website: entry.website,
                );
              },
              child: const Text('打开'),
            );
          }

          Widget plainOpenAction(_SiteTimelineEntry entry) {
            return GestureDetector(
              onTap: () async {
                final urls = entry.website.url.where((e) => e.trim().isNotEmpty).toList();
                if (urls.isEmpty) {
                  Toast.warning('该站点未配置可用 URL');
                  return;
                }
                if (urls.length == 1) {
                  if (!dialogContext.mounted) return;
                  Navigator.of(dialogContext).pop();
                  BrowserPage.open(
                    context,
                    url: urls.first,
                    title: entry.displayName,
                    siteId: entry.website.name,
                    website: entry.website,
                  );
                  return;
                }
                final selected = await shadcn.showDialog<String>(
                  context: dialogContext,
                  builder: (ctx) {
                    final cs = shadcn.Theme.of(ctx).colorScheme;
                    final typo = shadcn.Theme.of(ctx).typography;
                    return shadcn.AlertDialog(
                      title: const Text('选择站点地址'),
                      content: SizedBox(
                        width: 560,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 360),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (var i = 0; i < urls.length; i++) ...[
                                  GestureDetector(
                                    onTap: () => Navigator.of(ctx).pop(urls[i]),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                                      decoration: BoxDecoration(
                                        color: cs.muted.withValues(alpha: 0.16),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(shadcn.LucideIcons.globe, size: 15, color: cs.mutedForeground),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _timelineUrlHost(urls[i]),
                                                  style: typo.small.copyWith(
                                                    color: cs.foreground,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  urls[i],
                                                  style: typo.xSmall.copyWith(color: cs.mutedForeground),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(shadcn.LucideIcons.chevronRight, size: 15, color: cs.mutedForeground),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (i != urls.length - 1) const SizedBox(height: 6),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        shadcn.Button.outline(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('取消'),
                        ),
                      ],
                    );
                  },
                );
                if (selected == null || selected.isEmpty) return;
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                BrowserPage.open(
                  context,
                  url: selected,
                  title: entry.displayName,
                  siteId: entry.website.name,
                  website: entry.website,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.muted.withValues(alpha: 0.24),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '打开',
                  style: shadcn.Theme.of(dialogContext).typography.xSmall.copyWith(
                    color: cs.foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }

          final timelineData = <shadcn.TimelineData>[
            for (final entry in displayList)
              shadcn.TimelineData(
                color: entry.isOwned
                    ? (entry.isDisabled ? cs.mutedForeground.withValues(alpha: 0.72) : cs.primary)
                    : cs.mutedForeground.withValues(alpha: 0.42),
                time: const SizedBox.shrink(),
                title: const SizedBox.shrink(),
                content: _siteTimelineRow(
                  context: dialogContext,
                  entry: entry,
                  showDurationOnTitle: showDurationOnTitle,
                  visibleFields: visibleFields,
                  openUnownedAction: plainOpenAction,
                ),
              ),
          ];

          return shadcn.AlertDialog(
            title: const Text('站点时间轴'),
            content: SizedBox(
              width: context.isMobile ? double.infinity : 860,
              height: MediaQuery.of(dialogContext).size.height * 0.78,
              child: Column(
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      shadcn.Button.secondary(
                        onPressed: () => setState(() {
                          ownership = switch (ownership) {
                            _TimelineOwnership.all => _TimelineOwnership.ownedOnly,
                            _TimelineOwnership.ownedOnly => _TimelineOwnership.unownedOnly,
                            _TimelineOwnership.unownedOnly => _TimelineOwnership.all,
                          };
                        }),
                        child: Text(switch (ownership) {
                          _TimelineOwnership.all => '全部站点',
                          _TimelineOwnership.ownedOnly => '仅拥有站点',
                          _TimelineOwnership.unownedOnly => '未拥有站点',
                        }).xSmall,
                      ),
                      shadcn.Button.secondary(
                        onPressed: () => setState(() {
                          inviteFilter = switch (inviteFilter) {
                            _TimelineInviteFilter.all => _TimelineInviteFilter.has,
                            _TimelineInviteFilter.has => _TimelineInviteFilter.none,
                            _TimelineInviteFilter.none => _TimelineInviteFilter.all,
                          };
                        }),
                        child: Text(
                          switch (inviteFilter) {
                            _TimelineInviteFilter.all => '邀请：全部',
                            _TimelineInviteFilter.has => '邀请：有邀请',
                            _TimelineInviteFilter.none => '邀请：无邀请',
                          },
                        ).xSmall,
                      ),
                      shadcn.Button.secondary(
                        onPressed: () => setState(() => ascending = !ascending),
                        child: Text(ascending ? '注册时间正序' : '注册时间倒序').xSmall,
                      ),
                      shadcn.Button.secondary(
                        onPressed: () => setState(() {
                          showDurationOnTitle = !showDurationOnTitle;
                          HiveManager.set(
                            StorageKeys.siteTimelineTitleShowDuration,
                            showDurationOnTitle,
                          );
                        }),
                        child: Text(showDurationOnTitle ? '标题显示：注册时长' : '标题显示：注册日期').xSmall,
                      ),
                      shadcn.OverlayManagerLayer(
                        popoverHandler: const shadcn.PopoverOverlayHandler(),
                        tooltipHandler: const shadcn.FixedTooltipOverlayHandler(),
                        menuHandler: const shadcn.PopoverOverlayHandler(),
                        child: Builder(
                          builder: (menuContext) => shadcn.Button.ghost(
                            onPressed: () => shadcn.showDropdown<void>(
                              context: menuContext,
                              alignment: Alignment.topCenter,
                              offset: const Offset(0, 8),
                              consumeOutsideTaps: false,
                              builder: (_) => AppDropdownMenu(
                                children: [
                                  const shadcn.MenuLabel(child: Text('显示字段')),
                                  const shadcn.MenuDivider(),
                                  for (final item in const [
                                    ('duration', '注册时长'),
                                    ('uploaded', '上传量'),
                                    ('downloaded', '下载量'),
                                    ('invitation', '邀请数'),
                                    ('username', '用户名'),
                                    ('email', '邮箱'),
                                    ('uid', 'UID'),
                                  ])
                                    shadcn.MenuButton(
                                      onPressed: (_) => setState(() {
                                        visibleFields[item.$1] = !(visibleFields[item.$1] ?? true);
                                        HiveManager.set(StorageKeys.siteTimelineVisibleFields, visibleFields);
                                      }),
                                      child: Row(
                                        children: [
                                          Icon(
                                            (visibleFields[item.$1] ?? true)
                                                ? shadcn.LucideIcons.check
                                                : shadcn.LucideIcons.minus,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(item.$2),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            child: const Text('字段').xSmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: shadcn.ComponentTheme(
                      data: shadcn.TimelineTheme(
                        dotSize: 10,
                        spacing: 12,
                        rowGap: 10,
                        connectorThickness: 1.2,
                        color: cs.border.withValues(alpha: 0.65),
                        timeConstraints: const BoxConstraints.tightFor(width: 0),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(right: 6),
                        child: shadcn.Timeline(data: timelineData),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              shadcn.Button.outline(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('关闭'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openImportTomlDialog(BuildContext context) {
    var files = <PlatformFile>[];
    var uploading = false;
    var overwrite = false;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final theme = shadcn.Theme.of(ctx);
          final cs = theme.colorScheme;

          Future<void> selectFiles() async {
            FilePickerResult? result;
            try {
              result = await FilePicker.pickFiles(
                allowMultiple: true,
                type: FileType.custom,
                allowedExtensions: const ['toml'],
                withData: true,
              );
            } on PlatformException catch (e) {
              AppLogger.error('选择 TOML 配置文件失败', e);
              if (e.code == 'ENTITLEMENT_NOT_FOUND') {
                Toast.error('缺少文件读取权限，请重启应用后重试');
              } else {
                Toast.error('选择文件失败: ${e.message ?? e.code}');
              }
              return;
            } catch (e, st) {
              AppLogger.error('选择 TOML 配置文件失败', e, st);
              Toast.error('选择文件失败');
              return;
            }
            if (result == null) return;
            if (!ctx.mounted) return;

            final tomlFiles = result.files.where((file) => file.name.toLowerCase().endsWith('.toml')).toList();
            if (tomlFiles.length != result.files.length) {
              Toast.warning('仅支持 TOML 配置文件');
            }
            if (tomlFiles.isEmpty) return;

            AppLogger.info('已选择 TOML 配置文件: ${tomlFiles.map((file) => file.name).join(', ')}');
            setDialogState(() => files = tomlFiles);
          }

          Future<void> upload() async {
            if (files.isEmpty) {
              Toast.warning('请选择 TOML 配置文件');
              return;
            }
            if (files.any((file) => file.path == null && file.bytes == null)) {
              Toast.error('无法读取所选文件');
              return;
            }

            setDialogState(() => uploading = true);
            try {
              AppLogger.info('提交上传 TOML 配置文件: count=${files.length}, overwrite=$overwrite');
              await ref.read(siteInfoListProvider.notifier).importCustomSiteToml(files, overwrite: overwrite);
              if (ctx.mounted) closeAppSheet(ctx);
              Toast.success('站点配置已上传');
            } catch (e, st) {
              AppLogger.error('站点配置上传失败', e, st);
              if (ctx.mounted) setDialogState(() => uploading = false);
              Toast.error('站点配置上传失败');
            }
          }

          return shadcn.AlertDialog(
            content: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: ctx.isMobile ? MediaQuery.sizeOf(ctx).width - 40 : 460),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '上传站点配置',
                      style: theme.typography.large.copyWith(color: cs.foreground, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: shadcn.Button.outline(
                            onPressed: uploading ? null : selectFiles,
                            child: Text(files.isEmpty ? '选择 TOML 文件' : '重新选择 TOML 文件'),
                          ),
                        ),
                        if (files.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          shadcn.Button.ghost(
                            onPressed: uploading
                                ? null
                                : () {
                                    AppLogger.info('清除全部待上传 TOML 配置文件: count=${files.length}');
                                    setDialogState(() => files = []);
                                  },
                            child: const Text('一键清除'),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (files.isEmpty)
                      const _TomlUploadEmptyState()
                    else
                      _TomlFileList(
                        files: files,
                        onRemove: (index) {
                          AppLogger.info('移除待上传 TOML 配置文件: ${files[index].name}');
                          setDialogState(() => files = [...files]..removeAt(index));
                        },
                      ),
                    const SizedBox(height: 12),
                    _OverwriteOption(
                      overwrite: overwrite,
                      enabled: !uploading,
                      onChanged: (value) => setDialogState(() => overwrite = value),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: shadcn.Button.ghost(
                            onPressed: uploading ? null : () => closeAppSheet(ctx),
                            child: const Text('取消'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: shadcn.Button.primary(
                            onPressed: uploading ? null : upload,
                            child: uploading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: shadcn.CircularProgressIndicator(strokeWidth: 2.2),
                                  )
                                : Text('上传${files.isEmpty ? '' : ' ${files.length} 个'}'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OverwriteOption extends StatelessWidget {
  final bool overwrite;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _OverwriteOption({required this.overwrite, required this.enabled, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.muted.withValues(alpha: 0.28),
        borderRadius: siteRadius(context, size: "md"),
        border: Border.all(color: cs.border.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '覆盖同名配置',
                  style: theme.typography.small.copyWith(color: cs.foreground, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  overwrite ? '同名文件将被覆盖' : '同名文件保持原样',
                  style: theme.typography.xSmall.copyWith(color: cs.mutedForeground),
                ),
              ],
            ),
          ),
          shadcn.Switch(value: overwrite, onChanged: enabled ? onChanged : null),
        ],
      ),
    );
  }
}

class _TomlUploadEmptyState extends StatelessWidget {
  const _TomlUploadEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;

    return Container(
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cs.muted.withValues(alpha: 0.35),
        borderRadius: siteRadius(context, size: "md"),
        border: Border.all(color: cs.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(shadcn.LucideIcons.fileUp, size: 24, color: cs.mutedForeground),
          const SizedBox(height: 8),
          Text('支持多选 .toml 配置文件', style: typo.small.copyWith(color: cs.mutedForeground)),
        ],
      ),
    );
  }
}

class _TomlFileList extends StatelessWidget {
  final List<PlatformFile> files;
  final ValueChanged<int> onRemove;

  const _TomlFileList({required this.files, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 220),
      child: SingleChildScrollView(
        child: Column(
          children: [
            for (var i = 0; i < files.length; i++) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: cs.muted.withValues(alpha: 0.24),
                  borderRadius: siteRadius(context, size: "md"),
                  border: Border.all(color: cs.border.withValues(alpha: 0.65)),
                ),
                child: Row(
                  children: [
                    Icon(shadcn.LucideIcons.fileCode, size: 18, color: cs.mutedForeground),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            files[i].name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.typography.small.copyWith(color: cs.foreground, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formatBytes(files[i].size),
                            style: theme.typography.xSmall.copyWith(color: cs.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                    shadcn.IconButton.ghost(
                      onPressed: () => onRemove(i),
                      icon: const Icon(shadcn.LucideIcons.x, size: 16),
                    ),
                  ],
                ),
              ),
              if (i != files.length - 1) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _MobileFilterSheet extends ConsumerWidget {
  final TextEditingController searchCtrl;

  const _MobileFilterSheet({required this.searchCtrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sitesAsync = ref.watch(siteInfoListProvider);
    final filteredSites = ref.watch(filteredSiteListProvider);
    final filter = ref.watch(siteFilterStateProvider);
    final hasFilters = filter.hasActiveFilters;
    final totalCount = sitesAsync.valueOrNull?.length ?? 0;
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;
    final media = MediaQuery.of(context);
    final maxSheetHeight = (media.size.height - media.padding.top - media.viewInsets.bottom) * 0.72;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      child: Container(
        decoration: BoxDecoration(
          color: cs.background,
          borderRadius: BorderRadius.vertical(top: siteRadius(context, size: "xl").topLeft),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            // 搜索 + 计数
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${filteredSites.length}',
                          style: typo.small.copyWith(
                            fontWeight: FontWeight.w700,
                            color: hasFilters ? cs.primary : cs.foreground,
                          ),
                        ),
                        TextSpan(
                          text: ' / $totalCount',
                          style: typo.small.copyWith(color: cs.mutedForeground),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: ShadTextField(
                        controller: searchCtrl,
                        // 共用
                        hintText: '搜索站点...',
                        maxLines: 1,
                        onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                        features: [
                          shadcn.InputFeature.clear(
                            visibility: shadcn.InputFeatureVisibility.textNotEmpty,
                            icon: Icon(shadcn.LucideIcons.x, size: 12, color: cs.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 筛选面板（可滚动）
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: media.padding.bottom + 16),
                child: const SiteFilterPanel(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _siteTimelineRow({
  required BuildContext context,
  required _SiteTimelineEntry entry,
  required bool showDurationOnTitle,
  required Map<String, bool> visibleFields,
  required Widget Function(_SiteTimelineEntry entry) openUnownedAction,
}) {
  final theme = shadcn.Theme.of(context);
  final cs = theme.colorScheme;
  final titleTime = showDurationOnTitle ? entry.durationText : entry.registeredAtText;
  final showStates = entry.isDisabled || !entry.isOwned;
  final items = <_TimelineMetric>[
    if (visibleFields['uploaded'] == true)
      _TimelineMetric(
        label: '上传量',
        value: entry.uploadedText,
        icon: shadcn.LucideIcons.upload,
      ),
    if (visibleFields['downloaded'] == true)
      _TimelineMetric(
        label: '下载量',
        value: entry.downloadedText,
        icon: shadcn.LucideIcons.download,
      ),
    if (visibleFields['username'] == true)
      _TimelineMetric(
        label: '用户名',
        value: entry.usernameText,
        icon: shadcn.LucideIcons.userRound,
      ),
    if (visibleFields['email'] == true)
      _TimelineMetric(
        label: '邮箱',
        value: entry.emailText,
        icon: shadcn.LucideIcons.mail,
      ),
    if (visibleFields['uid'] == true)
      _TimelineMetric(
        label: 'UID',
        value: entry.uidText,
        icon: shadcn.LucideIcons.hash,
      ),
  ];

  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: cs.card,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: cs.border.withValues(alpha: 0.82)),
      boxShadow: [
        BoxShadow(
          color: cs.foreground.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
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
                entry.displayName,
                style: theme.typography.small.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.foreground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (visibleFields['invitation'] == true) ...[
                  _timelineInvitationBadge(
                    context,
                    count: entry.invitationCount,
                  ),
                  const SizedBox(width: 6),
                ],
                _timelineTitleMeta(
                  context,
                  icon: showDurationOnTitle ? shadcn.LucideIcons.clock : shadcn.LucideIcons.calendar,
                  text: titleTime,
                  tooltip: showDurationOnTitle ? '注册时长：$titleTime' : '注册时间：$titleTime',
                ),
                const SizedBox(width: 6),
                _timelineLinksIndicator(context, entry.website.url),
              ],
            ),
          ],
        ),
        if (showStates) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              if (entry.isDisabled) ...[
                _timelineStateTag(context, '已禁用'),
                const SizedBox(width: 6),
              ],
              if (!entry.isOwned) ...[
                _timelineStateTag(context, '未添加'),
                const SizedBox(width: 8),
                openUnownedAction(entry),
              ],
            ],
          ),
        ],
        if (items.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 8),
            height: 1,
            color: cs.border.withValues(alpha: 0.35),
          ),
          for (var i = 0; i < items.length; i += 2) ...[
            Row(
              children: [
                Expanded(
                  child: _timelineMetricTile(context, items[i]),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: i + 1 < items.length ? _timelineMetricTile(context, items[i + 1]) : const SizedBox.shrink(),
                ),
              ],
            ),
            if (i + 2 < items.length) const SizedBox(height: 8),
          ],
        ],
      ],
    ),
  );
}

Widget _timelineLinksIndicator(BuildContext context, List<String> urls) {
  final theme = shadcn.Theme.of(context);
  final cs = theme.colorScheme;
  final availableUrls = urls.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  final tooltip = availableUrls.isEmpty
      ? '暂无可访问链接'
      : [
          '可访问链接',
          for (final url in availableUrls) '${_timelineUrlHost(url)}\n$url',
        ].join('\n\n');
  final child = Container(
    width: 20,
    height: 20,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: cs.muted.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Icon(
      availableUrls.isEmpty ? shadcn.LucideIcons.globeLock : shadcn.LucideIcons.globe,
      size: 12,
      color: availableUrls.isEmpty ? cs.mutedForeground.withValues(alpha: 0.58) : cs.primary,
    ),
  );

  return shadcn.Tooltip(
    tooltip: (_) => Text(
      tooltip,
      style: theme.typography.xSmall.copyWith(color: cs.foreground),
    ),
    child: child,
  );
}

Widget _timelineInvitationBadge(BuildContext context, {required int count}) {
  final theme = shadcn.Theme.of(context);
  final cs = theme.colorScheme;
  final child = shadcn.SecondaryBadge(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(shadcn.LucideIcons.ticket, size: 11, color: cs.foreground),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: theme.typography.xSmall.copyWith(
            color: cs.foreground,
            fontWeight: FontWeight.w800,
            fontSize: 10.5,
          ),
        ),
      ],
    ),
  );

  return shadcn.Tooltip(
    tooltip: (_) => Text('邀请数：$count'),
    child: child,
  );
}

Widget _timelineTitleMeta(
  BuildContext context, {
  required IconData icon,
  required String text,
  required String tooltip,
}) {
  final theme = shadcn.Theme.of(context);
  final cs = theme.colorScheme;
  final child = Container(
    constraints: const BoxConstraints(maxWidth: 120),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: cs.muted.withValues(alpha: 0.24),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: cs.mutedForeground),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: theme.typography.xSmall.copyWith(
              color: cs.mutedForeground,
              fontWeight: FontWeight.w700,
              fontSize: 10.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );

  return shadcn.Tooltip(
    tooltip: (_) => Text(tooltip),
    child: child,
  );
}

class _TimelineMetric {
  final String label;
  final String value;
  final IconData icon;

  const _TimelineMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  String get tooltip => '$label：$value';
}

Widget _timelineMetricTile(BuildContext context, _TimelineMetric metric) {
  final theme = shadcn.Theme.of(context);
  final cs = theme.colorScheme;
  final tile = Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
    decoration: BoxDecoration(
      color: cs.muted.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: cs.border.withValues(alpha: 0.42)),
    ),
    child: Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(metric.icon, size: 13, color: cs.primary),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                metric.label,
                style: theme.typography.xSmall.copyWith(
                  color: cs.mutedForeground,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                metric.value,
                style: theme.typography.xSmall.copyWith(
                  color: cs.foreground,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );

  return shadcn.Tooltip(
    tooltip: (_) => Text(metric.tooltip),
    child: tile,
  );
}

Widget _timelineStateTag(BuildContext context, String text) {
  final theme = shadcn.Theme.of(context);
  final cs = theme.colorScheme;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: cs.muted.withValues(alpha: 0.24),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: cs.border.withValues(alpha: 0.7)),
    ),
    child: Text(
      text,
      style: theme.typography.xSmall.copyWith(
        color: cs.mutedForeground,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

String _timelineUrlHost(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null) return url;
  return uri.host.isEmpty ? url : uri.host;
}

enum _TimelineOwnership { all, ownedOnly, unownedOnly }

enum _TimelineInviteFilter { all, has, none }

class _SiteTimelineEntry {
  final WebSite website;
  final SiteInfo? mySite;

  const _SiteTimelineEntry({required this.website, required this.mySite});

  bool get isOwned => mySite != null;
  bool get isDisabled => mySite?.available == false;

  String get displayName {
    final nick = mySite?.nickname.trim() ?? website.nickname.trim();
    if (nick.isNotEmpty) return nick;
    final site = mySite?.site.trim() ?? website.name.trim();
    if (site.isNotEmpty) return site;
    return '未命名站点';
  }

  DateTime? get registeredAt {
    final raw = mySite?.timeJoin?.trim() ?? '';
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  String get registeredAtText {
    final dt = registeredAt;
    if (dt == null) return '未登记';
    final local = dt.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String get durationText => mySite?.durationText ?? '-';

  int get uploadedBytes => mySite?.latestStatus?.uploaded ?? 0;

  int get downloadedBytes => mySite?.latestStatus?.downloaded ?? 0;

  int get invitationCount => mySite?.latestStatus?.invitation ?? 0;

  String get uploadedText => uploadedBytes > 0 ? formatBytes(uploadedBytes) : '-';

  String get downloadedText => downloadedBytes > 0 ? formatBytes(downloadedBytes) : '-';

  String get usernameText => mySite?.username?.trim().isNotEmpty == true ? mySite!.username!.trim() : '-';

  String get emailText => mySite?.email?.trim().isNotEmpty == true ? mySite!.email!.trim() : '-';

  String get uidText => mySite?.userId?.trim().isNotEmpty == true ? mySite!.userId!.trim() : '-';
}
