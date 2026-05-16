import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/storage/storage_keys.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/site/model/site_config.dart';
import 'package:harvest/modules/site/model/site_info.dart';
import 'package:harvest/modules/site/provider/site_provider.dart';
import 'package:harvest/modules/site/widgets/site_browser.dart';
import 'package:harvest/widgets/app_menu.dart';
import 'package:harvest/widgets/app_header_layout.dart';
import 'package:harvest/widgets/browser_page.dart';
import 'package:harvest/widgets/escape_back_scope.dart';
import 'package:harvest/modules/shell/widgets/global_drawer_swipe_area.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

Future<void> showSiteTimelineDialog(BuildContext context) async {
  await shadcn.showDialog<void>(
    context: context,
    builder: (dialogContext) => shadcn.AlertDialog(
      title: const Text('站点时间轴'),
      content: SizedBox(
        width: context.isMobile ? double.infinity : 860,
        height: MediaQuery.of(dialogContext).size.height * 0.78,
        child: SiteTimelineContent(
          closeContainerOnOpen: true,
          openContext: context,
        ),
      ),
      actions: [
        shadcn.Button.outline(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('关闭'),
        ),
      ],
    ),
  );
}

class SiteTimelinePage extends ConsumerWidget {
  const SiteTimelinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final pageBackground = cs.background;

    return EscapeBackScope(
      onBack: () => Navigator.of(context).pop(),
      child: GlobalDrawerSwipeArea(
        child: shadcn.Scaffold(
          backgroundColor: pageBackground,
          headerBackgroundColor: pageBackground,
          headers: [
            shadcn.AppBar(
              height: kAppHeaderHeight - 12,
              padding: appHeaderPadding(context),
              backgroundColor: pageBackground,
              title: Text(
                '站点时间轴',
                style: theme.typography.large.copyWith(
                  color: cs.foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              leading: [
                shadcn.IconButton.ghost(
                  icon: const Icon(shadcn.LucideIcons.arrowLeft, size: 18),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ],
          child: const Padding(
            padding: EdgeInsets.fromLTRB(12, 8, 12, 16),
            child: SiteTimelineContent(),
          ),
        ),
      ),
    );
  }
}

class SiteTimelineContent extends ConsumerStatefulWidget {
  final bool closeContainerOnOpen;
  final BuildContext? openContext;

  const SiteTimelineContent({
    super.key,
    this.closeContainerOnOpen = false,
    this.openContext,
  });

  @override
  ConsumerState<SiteTimelineContent> createState() =>
      _SiteTimelineContentState();
}

class _SiteTimelineContentState extends ConsumerState<SiteTimelineContent> {
  var _ownership = _TimelineOwnership.all;
  var _inviteFilter = _TimelineInviteFilter.all;
  var _sortMode = _TimelineSortMode.registeredAt;
  var _ascending = true;
  late bool _showDurationOnTitle;
  late final Map<String, bool> _visibleFields;

  @override
  void initState() {
    super.initState();
    _showDurationOnTitle =
        HiveManager.get<bool>(StorageKeys.siteTimelineTitleShowDuration) ??
        false;
    _visibleFields = _defaultVisibleFields();
    final savedVisibleFields = HiveManager.get<Map>(
      StorageKeys.siteTimelineVisibleFields,
    );
    if (savedVisibleFields != null) {
      for (final entry in savedVisibleFields.entries) {
        final key = entry.key.toString();
        if (_visibleFields.containsKey(key)) {
          _visibleFields[key] = entry.value == true;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final websitesAsync = ref.watch(websiteListProvider);
    final mySitesAsync = ref.watch(siteInfoListProvider);
    final websites = websitesAsync.valueOrNull ?? const <WebSite>[];
    final mySites = mySitesAsync.valueOrNull ?? const <SiteInfo>[];
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;

    if (websitesAsync.isLoading || mySitesAsync.isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const shadcn.CircularProgressIndicator(strokeWidth: 2),
            const SizedBox(height: 10),
            Text(
              '加载站点时间轴...',
              style: theme.typography.small.copyWith(color: cs.mutedForeground),
            ),
          ],
        ),
      );
    }

    if (websites.isEmpty) {
      return Center(
        child: Text(
          '暂无站点配置',
          style: theme.typography.small.copyWith(color: cs.mutedForeground),
        ),
      );
    }

    final entries = _buildEntries(websites, mySites);
    final displayList = _filterEntries(entries);
    final timelineData = <shadcn.TimelineData>[
      for (final entry in displayList)
        shadcn.TimelineData(
          color: entry.isOwned
              ? (entry.isDisabled
                    ? cs.mutedForeground.withValues(alpha: 0.72)
                    : cs.primary)
              : cs.mutedForeground.withValues(alpha: 0.42),
          time: const SizedBox.shrink(),
          title: const SizedBox.shrink(),
          content: _siteTimelineRow(
            context: context,
            entry: entry,
            showDurationOnTitle: _showDurationOnTitle,
            visibleFields: _visibleFields,
            openUnownedAction: _plainOpenAction,
            onOpenUrl: _openEntryUrl,
          ),
        ),
    ];

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _timelineDropdownButton(
                label: '筛选',
                children: [
                  const shadcn.MenuLabel(child: Text('站点范围')),
                  for (final item in _TimelineOwnership.values)
                    _timelineMenuButton(
                      selected: _ownership == item,
                      label: _ownershipLabel(item),
                      onPressed: () => setState(() => _ownership = item),
                    ),
                ],
              ),
              const SizedBox(width: 6),
              _timelineDropdownButton(
                label: '邀请',
                children: [
                  const shadcn.MenuLabel(child: Text('邀请筛选')),
                  for (final item in _TimelineInviteFilter.values)
                    _timelineMenuButton(
                      selected: _inviteFilter == item,
                      label: _inviteFilterLabel(item),
                      onPressed: () => setState(() => _inviteFilter = item),
                    ),
                ],
              ),
              const SizedBox(width: 6),
              _timelineDropdownButton(
                label: '排序',
                children: [
                  const shadcn.MenuLabel(child: Text('排序字段')),
                  for (final item in _TimelineSortMode.values)
                    _timelineMenuButton(
                      selected: _sortMode == item,
                      label: _sortModeLabel(item),
                      onPressed: () => setState(() => _sortMode = item),
                    ),
                  const shadcn.MenuDivider(),
                  const shadcn.MenuLabel(child: Text('排序方向')),
                  _timelineMenuButton(
                    selected: _ascending,
                    label: '正序',
                    onPressed: () => setState(() => _ascending = true),
                  ),
                  _timelineMenuButton(
                    selected: !_ascending,
                    label: '倒序',
                    onPressed: () => setState(() => _ascending = false),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              _timelineDropdownButton(
                label: '显示',
                children: [
                  const shadcn.MenuLabel(child: Text('标题')),
                  _timelineMenuButton(
                    selected: !_showDurationOnTitle,
                    label: '标题显示：注册日期',
                    onPressed: () => setState(() {
                      _showDurationOnTitle = false;
                      HiveManager.set(
                        StorageKeys.siteTimelineTitleShowDuration,
                        _showDurationOnTitle,
                      );
                    }),
                  ),
                  _timelineMenuButton(
                    selected: _showDurationOnTitle,
                    label: '标题显示：注册时长',
                    onPressed: () => setState(() {
                      _showDurationOnTitle = true;
                      HiveManager.set(
                        StorageKeys.siteTimelineTitleShowDuration,
                        _showDurationOnTitle,
                      );
                    }),
                  ),
                  const shadcn.MenuDivider(),
                  const shadcn.MenuLabel(child: Text('显示字段')),
                  for (final item in const [
                    ('duration', '注册时长'),
                    ('uploaded', '上传量'),
                    ('downloaded', '下载量'),
                    ('invitation', '邀请数'),
                    ('username', '用户名'),
                    ('email', '邮箱'),
                    ('uid', 'UID'),
                  ])
                    _timelineMenuButton(
                      selected: _visibleFields[item.$1] ?? true,
                      label: item.$2,
                      onPressed: () => setState(() {
                        _visibleFields[item.$1] =
                            !(_visibleFields[item.$1] ?? true);
                        HiveManager.set(
                          StorageKeys.siteTimelineVisibleFields,
                          _visibleFields,
                        );
                      }),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: displayList.isEmpty
              ? Center(
                  child: Text(
                    '没有符合条件的站点',
                    style: theme.typography.small.copyWith(
                      color: cs.mutedForeground,
                    ),
                  ),
                )
              : shadcn.ComponentTheme(
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
    );
  }

  Widget _timelineDropdownButton({
    required String label,
    required List<shadcn.MenuItem> children,
  }) {
    return shadcn.OverlayManagerLayer(
      popoverHandler: const shadcn.PopoverOverlayHandler(),
      tooltipHandler: const shadcn.FixedTooltipOverlayHandler(),
      menuHandler: const shadcn.PopoverOverlayHandler(),
      child: Builder(
        builder: (menuContext) => shadcn.Button.secondary(
          onPressed: () => shadcn.showDropdown<void>(
            context: menuContext,
            alignment: Alignment.topRight,
            offset: const Offset(0, 8),
            consumeOutsideTaps: false,
            builder: (_) => AppDropdownMenu(children: children),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label),
              const SizedBox(width: 6),
              const Icon(shadcn.LucideIcons.chevronDown, size: 13),
            ],
          ).xSmall,
        ),
      ),
    );
  }

  shadcn.MenuButton _timelineMenuButton({
    required bool selected,
    required String label,
    required VoidCallback onPressed,
  }) {
    return shadcn.MenuButton(
      onPressed: (_) => onPressed(),
      child: Row(
        children: [
          Icon(
            selected ? shadcn.LucideIcons.check : shadcn.LucideIcons.minus,
            size: 14,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  List<_SiteTimelineEntry> _buildEntries(
    List<WebSite> websites,
    List<SiteInfo> mySites,
  ) {
    final byName = <String, SiteInfo>{};
    for (final site in mySites) {
      byName[site.site.trim().toLowerCase()] = site;
    }
    return websites.map((website) {
      final owned = byName[website.name.trim().toLowerCase()];
      return _SiteTimelineEntry(website: website, mySite: owned);
    }).toList();
  }

  List<_SiteTimelineEntry> _filterEntries(List<_SiteTimelineEntry> entries) {
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
      if (_ownership == _TimelineOwnership.ownedOnly && !entry.isOwned) {
        return false;
      }
      if (_ownership == _TimelineOwnership.unownedOnly && entry.isOwned) {
        return false;
      }
      final invites = entry.invitationCount;
      if (_inviteFilter == _TimelineInviteFilter.has && invites <= 0) {
        return false;
      }
      if (_inviteFilter == _TimelineInviteFilter.none && invites > 0) {
        return false;
      }
      return true;
    }

    int sortEntries(_SiteTimelineEntry a, _SiteTimelineEntry b) {
      if (_sortMode == _TimelineSortMode.invitation) {
        final cmp = a.invitationCount.compareTo(b.invitationCount);
        if (cmp != 0) return _ascending ? cmp : -cmp;
        return a.displayName.compareTo(b.displayName);
      }
      final at = a.registeredAt;
      final bt = b.registeredAt;
      if (at == null && bt == null) {
        return a.displayName.compareTo(b.displayName);
      }
      if (at == null) return 1;
      if (bt == null) return -1;
      final cmp = at.compareTo(bt);
      return _ascending ? cmp : -cmp;
    }

    final filteredEnabledOwned = enabledOwnedEntries.where(matches).toList()
      ..sort(sortEntries);
    final filteredDisabledOwned = disabledOwnedEntries.where(matches).toList()
      ..sort(sortEntries);
    final filteredUnowned = unownedEntries.where(matches).toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));
    return [
      ...filteredEnabledOwned,
      ...filteredDisabledOwned,
      ...filteredUnowned,
    ];
  }

  Widget _plainOpenAction(_SiteTimelineEntry entry) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => _openEntry(entry),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: cs.muted.withValues(alpha: 0.24),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '打开',
          style: shadcn.Theme.of(context).typography.xSmall.copyWith(
            color: cs.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _openEntry(_SiteTimelineEntry entry) async {
    final urls = entry.website.url.where((e) => e.trim().isNotEmpty).toList();
    if (urls.isEmpty) {
      Toast.warning('该站点未配置可用 URL');
      return;
    }
    if (urls.length == 1) {
      if (!mounted) return;
      final openContext = widget.openContext ?? context;
      if (widget.closeContainerOnOpen) Navigator.of(context).pop();
      BrowserPage.open(
        openContext,
        url: urls.first,
        title: entry.displayName,
        siteId: entry.website.name,
        website: entry.website,
      );
      return;
    }
    final selected = await shadcn.showDialog<String>(
      context: context,
      builder: (ctx) => _SiteUrlSelectDialog(urls: urls),
    );
    if (selected == null || selected.isEmpty || !mounted) return;
    final openContext = widget.openContext ?? context;
    if (!openContext.mounted) return;
    if (widget.closeContainerOnOpen) Navigator.of(context).pop();
    BrowserPage.open(
      openContext,
      url: selected,
      title: entry.displayName,
      siteId: entry.website.name,
      website: entry.website,
    );
  }

  void _openEntryUrl(_SiteTimelineEntry entry, String url) {
    final targetUrl = url.trim();
    if (targetUrl.isEmpty) {
      Toast.warning('该站点未配置可用 URL');
      return;
    }
    final openContext = widget.openContext ?? context;
    final mySite = entry.mySite;
    if (widget.closeContainerOnOpen) Navigator.of(context).pop();
    BrowserPage.open(
      openContext,
      url: targetUrl,
      title: entry.displayName,
      siteId: entry.website.name,
      website: entry.website,
      cookie: mySite?.cookie,
      userAgent: mySite?.userAgent,
    );
  }
}

Map<String, bool> _defaultVisibleFields() => {
  'duration': false,
  'uploaded': false,
  'downloaded': false,
  'invitation': true,
  'username': false,
  'email': false,
  'uid': false,
};

class _SiteUrlSelectDialog extends StatelessWidget {
  final List<String> urls;

  const _SiteUrlSelectDialog({required this.urls});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final typo = shadcn.Theme.of(context).typography;
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
                    onTap: () => Navigator.of(context).pop(urls[i]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: cs.muted.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            shadcn.LucideIcons.globe,
                            size: 15,
                            color: cs.mutedForeground,
                          ),
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
                                  style: typo.xSmall.copyWith(
                                    color: cs.mutedForeground,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            shadcn.LucideIcons.chevronRight,
                            size: 15,
                            color: cs.mutedForeground,
                          ),
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
      ],
    );
  }
}

Widget _siteTimelineRow({
  required BuildContext context,
  required _SiteTimelineEntry entry,
  required bool showDurationOnTitle,
  required Map<String, bool> visibleFields,
  required Widget Function(_SiteTimelineEntry entry) openUnownedAction,
  required void Function(_SiteTimelineEntry entry, String url) onOpenUrl,
}) {
  final theme = shadcn.Theme.of(context);
  final cs = theme.colorScheme;
  final titleTime = showDurationOnTitle
      ? entry.durationText
      : entry.registeredAtText;
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
                  icon: showDurationOnTitle
                      ? shadcn.LucideIcons.clock
                      : shadcn.LucideIcons.calendar,
                  text: titleTime,
                  tooltip: showDurationOnTitle
                      ? '注册时长：$titleTime'
                      : '注册时间：$titleTime',
                ),
                const SizedBox(width: 6),
                _timelineLinksIndicator(
                  context,
                  entry: entry,
                  urls: entry.website.url,
                  onOpenUrl: onOpenUrl,
                ),
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
                Expanded(child: _timelineMetricTile(context, items[i])),
                const SizedBox(width: 8),
                Expanded(
                  child: i + 1 < items.length
                      ? _timelineMetricTile(context, items[i + 1])
                      : const SizedBox.shrink(),
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

Widget _timelineLinksIndicator(
  BuildContext context, {
  required _SiteTimelineEntry entry,
  required List<String> urls,
  required void Function(_SiteTimelineEntry entry, String url) onOpenUrl,
}) {
  final theme = shadcn.Theme.of(context);
  final cs = theme.colorScheme;
  final fallbackUrls = urls
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
  final ownedTargets = entry.mySite == null
      ? const <SiteBrowseTarget>[]
      : buildSiteBrowseTargets(entry.mySite!, entry.website);
  final targets = ownedTargets.isNotEmpty
      ? ownedTargets
      : [
          for (final url in fallbackUrls)
            SiteBrowseTarget(
              label: _timelineUrlHost(url),
              url: url,
              icon: shadcn.LucideIcons.globe,
            ),
        ];
  final badge = _timelineLinksBadge(context, targets.isNotEmpty);

  if (targets.isEmpty) {
    return shadcn.Tooltip(
      tooltip: (_) => Text(
        '暂无可访问链接',
        style: theme.typography.xSmall.copyWith(color: cs.foreground),
      ),
      child: badge,
    );
  }

  return BrowserCookieQuickMenu(
    targets: targets,
    menuLabel: ownedTargets.isNotEmpty ? '快速跳转' : '可访问链接',
    badge: badge,
    onSelected: (target) => onOpenUrl(entry, target.url),
  );
}

Widget _timelineLinksBadge(BuildContext context, bool hasTargets) {
  final cs = shadcn.Theme.of(context).colorScheme;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
    height: 20,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: cs.muted.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          hasTargets ? shadcn.LucideIcons.globe : shadcn.LucideIcons.globeLock,
          size: 12,
          color: hasTargets
              ? cs.primary
              : cs.mutedForeground.withValues(alpha: 0.58),
        ),
        if (hasTargets) ...[
          const SizedBox(width: 3),
          Icon(shadcn.LucideIcons.chevronDown, size: 10, color: cs.primary),
        ],
      ],
    ),
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

  return shadcn.Tooltip(tooltip: (_) => Text('邀请数：$count'), child: child);
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

  return shadcn.Tooltip(tooltip: (_) => Text(tooltip), child: child);
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

  return shadcn.Tooltip(tooltip: (_) => Text(metric.tooltip), child: tile);
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

enum _TimelineSortMode { registeredAt, invitation }

String _ownershipLabel(_TimelineOwnership ownership) => switch (ownership) {
  _TimelineOwnership.all => '全部站点',
  _TimelineOwnership.ownedOnly => '仅拥有站点',
  _TimelineOwnership.unownedOnly => '未拥有站点',
};

String _inviteFilterLabel(_TimelineInviteFilter filter) => switch (filter) {
  _TimelineInviteFilter.all => '邀请：全部',
  _TimelineInviteFilter.has => '邀请：有邀请',
  _TimelineInviteFilter.none => '邀请：无邀请',
};

String _sortModeLabel(_TimelineSortMode mode) => switch (mode) {
  _TimelineSortMode.registeredAt => '注册时间',
  _TimelineSortMode.invitation => '邀请数量',
};

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

  String get uploadedText =>
      uploadedBytes > 0 ? formatBytes(uploadedBytes) : '-';

  String get downloadedText =>
      downloadedBytes > 0 ? formatBytes(downloadedBytes) : '-';

  String get usernameText => mySite?.username?.trim().isNotEmpty == true
      ? mySite!.username!.trim()
      : '-';

  String get emailText =>
      mySite?.email?.trim().isNotEmpty == true ? mySite!.email!.trim() : '-';

  String get uidText =>
      mySite?.userId?.trim().isNotEmpty == true ? mySite!.userId!.trim() : '-';
}
