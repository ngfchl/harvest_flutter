import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/theme/app_surface.dart';
import 'package:harvest/widgets/shadcn_compat.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'site_theme.dart';

import '../provider/site_filter_state.dart';
import '../provider/site_filtered_provider.dart';

class SiteFilterPanel extends ConsumerWidget {
  final VoidCallback? onClose;

  const SiteFilterPanel({super.key, this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(siteFilterStateProvider);
    final tags = ref.watch(availableTagsProvider);
    final siteTypes = ref.watch(availableSiteTypesProvider);
    final usernames = ref.watch(availableSiteUsernamesProvider);
    final emails = ref.watch(availableSiteEmailsProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;
    final tokens = SiteCardTokens.of(context);
    final gap = tokens.size(8);

    return AppSurfaceContainer(
      color: appSurfaceColor(context, cs.background),
      borderRadius: BorderRadius.zero,
      borderColor: cs.border.withValues(alpha: 0.42),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 标题栏 ──
          Padding(
            padding: tokens.edgeFromLTRB(16, 12, 12, 0),
            child: Row(
              children: [
                Icon(LucideIcons.slidersHorizontal, size: 15, color: cs.mutedForeground),
                SizedBox(width: tokens.size(6)),
                Text(
                  '筛选与排序',
                  style: typo.small.copyWith(fontWeight: FontWeight.w600, color: cs.foreground),
                ),
                const Spacer(),
                if (filter.hasActiveFilters)
                  GestureDetector(
                    onTap: () => filter.clearAll(),
                    child: Padding(
                      padding: EdgeInsets.all(tokens.size(4)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.x, size: 12, color: cs.mutedForeground),
                          SizedBox(width: tokens.size(3)),
                          Text('清除全部', style: typo.xSmall.copyWith(color: cs.mutedForeground)),
                        ],
                      ),
                    ),
                  ),
                if (onClose != null) ...[
                  SizedBox(width: tokens.size(8)),
                  IconButton.ghost(
                    onPressed: onClose,
                    icon: Icon(LucideIcons.panelRightClose, size: 15, color: cs.mutedForeground),
                  ),
                ],
              ],
            ),
          ),

          // ── 站点状态 ──
          _section(
            context,
            '站点状态',
            Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [SiteAvailabilityFilter.all, SiteAvailabilityFilter.alive, SiteAvailabilityFilter.dead].map((
                value,
              ) {
                return _chip(
                  context,
                  label: _availabilityLabel(value),
                  active: filter.availability == value,
                  showCheck: true,
                  onTap: () => filter.setAvailability(value),
                );
              }).toList(),
            ),
          ),

          // ── 条件筛选 ──
          _section(
            context,
            '条件筛选',
            Wrap(
              spacing: gap,
              runSpacing: gap,
              children:
                  [
                    FilterCondition.all,
                    ...FilterCondition.values.where(
                      (c) => c != FilterCondition.all && c != FilterCondition.alive && c != FilterCondition.dead,
                    ),
                  ].map((c) {
                    return _chip(
                      context,
                      label: _conditionLabel(c),
                      active: filter.condition == c,
                      showCheck: true,
                      onTap: () => filter.setCondition(c),
                    );
                  }).toList(),
            ),
          ),

          // ── 用户名 ──
          if (usernames.isNotEmpty)
            _section(
              context,
              '用户名筛选',
              _identityChips(
                context,
                values: usernames,
                selectedValue: filter.selectedUsername,
                clear: filter.clearUsername,
                select: filter.setUsername,
              ),
            ),

          // ── 邮箱 ──
          if (emails.isNotEmpty)
            _section(
              context,
              '邮箱筛选',
              _identityChips(
                context,
                values: emails,
                selectedValue: filter.selectedEmail,
                clear: filter.clearEmail,
                select: filter.setEmail,
              ),
            ),

          // ── 排序 ──
          _section(
            context,
            '排序方式',
            Wrap(
              spacing: gap,
              runSpacing: gap,
              children: SortField.values.map((f) {
                final active = filter.sortField == f;
                return _chip(
                  context,
                  label: _sortFieldLabel(f),
                  active: active,
                  onTap: () => filter.setSortField(f),
                  trailing: active
                      ? Icon(
                          filter.sortAscending ? LucideIcons.arrowUpRight : LucideIcons.arrowDownRight,
                          size: 12,
                          color: cs.primary,
                        )
                      : null,
                );
              }).toList(),
            ),
          ),

          // ── 站点类型 ──
          if (siteTypes.isNotEmpty)
            _section(
              context,
              '站点类型',
              Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  _chip(
                    context,
                    label: '全部',
                    active: filter.selectedSiteTypes.isEmpty,
                    showCheck: true,
                    onTap: filter.clearSiteTypes,
                  ),
                  ...siteTypes.map((type) {
                    return _chip(
                      context,
                      label: type,
                      active: filter.selectedSiteTypes.contains(type),
                      showCheck: true,
                      onTap: () => filter.toggleSiteType(type),
                    );
                  }),
                ],
              ),
            ),

          // ── 标签 ──
          if (tags.isNotEmpty)
            _section(
              context,
              '标签筛选',
              Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  _chip(
                    context,
                    label: '全部',
                    active: filter.selectedTags.isEmpty,
                    showCheck: true,
                    onTap: filter.clearTags,
                  ),
                  ...tags.map((tag) {
                    return _chip(
                      context,
                      label: '#$tag',
                      active: filter.selectedTags.contains(tag),
                      showCheck: true,
                      onTap: () => filter.toggleTag(tag),
                    );
                  }),
                ],
              ),
            ),

          SizedBox(height: tokens.size(12)),
        ],
      ),
    );
  }

  Widget _identityChips(
    BuildContext context, {
    required List<String> values,
    required String? selectedValue,
    required VoidCallback clear,
    required ValueChanged<String> select,
  }) {
    final maxLabelWidth = (MediaQuery.sizeOf(context).width - 96).clamp(120.0, 240.0);
    final gap = SiteCardTokens.of(context).size(8);

    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [
        _chip(context, label: '全部', active: selectedValue == null, showCheck: true, onTap: clear),
        ...values.map((value) {
          final active = _normalizeIdentity(selectedValue) == _normalizeIdentity(value);
          return _chip(
            context,
            label: value,
            active: active,
            showCheck: true,
            onTap: () => select(value),
            constrainLabel: true,
            maxLabelWidth: maxLabelWidth,
          );
        }),
      ],
    );
  }

  /// 统一的筛选选项 chip:选中态高亮 + 勾选标记,间距与触摸目标舒适。
  Widget _chip(
    BuildContext context, {
    required String label,
    required bool active,
    required VoidCallback onTap,
    bool showCheck = false,
    Widget? trailing,
    bool constrainLabel = false,
    double maxLabelWidth = 160,
  }) {
    final cs = Theme.of(context).colorScheme;
    final typo = Theme.of(context).typography;
    final tokens = SiteCardTokens.of(context);
    final labelStyle = TextStyle(
      fontSize: typo.xSmall.fontSize ?? 12.5,
      color: active ? cs.primary : cs.foreground.withValues(alpha: 0.82),
      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
    );

    Widget labelWidget = Text(label, style: labelStyle);
    if (constrainLabel) {
      labelWidget = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxLabelWidth),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: labelStyle),
      );
    }

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          labelWidget,
          if (trailing != null) ...[SizedBox(width: tokens.size(4)), trailing],
        ],
      ),
      selected: active,
      showCheckmark: showCheck,
      onSelected: (_) => onTap(),
      selectedColor: cs.primary.withValues(alpha: 0.14),
      side: BorderSide(color: active ? cs.primary.withValues(alpha: 0.85) : cs.border.withValues(alpha: 0.55)),
      labelStyle: labelStyle,
      padding: tokens.symmetric(horizontal: 11, vertical: 6),
    );
  }

  static String _normalizeIdentity(String? value) => value?.trim().toLowerCase() ?? '';

  Widget _section(BuildContext context, String label, Widget child) {
    final theme = Theme.of(context);
    final tokens = SiteCardTokens.of(context);
    return Padding(
      padding: tokens.edgeFromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: tokens.size(3),
                height: tokens.size(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.55),
                  borderRadius: siteRadius(context, size: 'xs'),
                ),
              ),
              SizedBox(width: tokens.size(6)),
              Text(
                label,
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.foreground.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.size(8)),
          child,
        ],
      ),
    );
  }

  // ── labels（不变） ──

  static String _availabilityLabel(SiteAvailabilityFilter value) {
    switch (value) {
      case SiteAvailabilityFilter.all:
        return '全部';
      case SiteAvailabilityFilter.alive:
        return '存活';
      case SiteAvailabilityFilter.dead:
        return '死亡';
    }
  }

  static String _conditionLabel(FilterCondition c) {
    switch (c) {
      case FilterCondition.all:
        return '全部';
      case FilterCondition.alive:
        return '站点存活';
      case FilterCondition.dead:
        return '站点死亡';
      case FilterCondition.notSignedIn:
        return '未签到';
      case FilterCondition.hasNewMessage:
        return '有新邮件';
      case FilterCondition.hasNewAnnouncement:
        return '有新公告';
      case FilterCondition.hasNewNotification:
        return '有新通知';
      case FilterCondition.noTodayData:
        return '无今日数据';
      case FilterCondition.hasUploadDelta:
        return '有上传增量';
      case FilterCondition.hasDownloadDelta:
        return '有下载增量';
      case FilterCondition.hasDelta:
        return '有增量';
      case FilterCondition.noProxy:
        return '无Proxy';
      case FilterCondition.noUid:
        return '无UID';
      case FilterCondition.noUsername:
        return '无用户名';
      case FilterCondition.noEmail:
        return '无邮箱';
      case FilterCondition.noSignInRecord:
        return '无签到记录';
      case FilterCondition.noCookie:
        return '无Cookie';
      case FilterCondition.noPasskey:
        return '无Passkey';
      case FilterCondition.noAuthKey:
        return '无Authkey';
      case FilterCondition.noSiteData:
        return '无站点数据';
      case FilterCondition.abnormalRegTime:
        return '注册时间异常';
      case FilterCondition.hasInvitation:
        return '有邀请';
      case FilterCondition.keepAccount:
        return '已保号';
      case FilterCondition.graduated:
        return '已毕业';
      case FilterCondition.noSeeding:
        return '无做种';
      case FilterCondition.hasDownloading:
        return '有下载';
      case FilterCondition.abnormalShareRatio:
        return '分享率异常';
    }
  }

  static String _sortFieldLabel(SortField f) {
    switch (f) {
      case SortField.updatedAt:
        return '更新时间';
      case SortField.siteName:
        return '站点名称';
      case SortField.nickname:
        return '昵称';
      case SortField.regTime:
        return '注册时间';
      case SortField.lastVisit:
        return '最后访问';
      case SortField.seedingSize:
        return '做种体积';
      case SortField.magic:
        return '魔力';
      case SortField.credits:
        return '积分';
      case SortField.upload:
        return '上传量';
      case SortField.uploadDelta:
        return '上传增量';
      case SortField.download:
        return '下载量';
      case SortField.downloadDelta:
        return '下载增量';
      case SortField.seedCount:
        return '发种数';
      case SortField.hourlyMagic:
        return '时魔';
      case SortField.invitation:
        return '邀请';
      case SortField.downloading:
        return '正在下载';
      case SortField.seeding:
        return '正在做种';
      case SortField.shareRatio:
        return '分享率';
      case SortField.sortId:
        return '排序 ID';
    }
  }
}
