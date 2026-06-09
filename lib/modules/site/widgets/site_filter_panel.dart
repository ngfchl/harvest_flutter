import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/theme/app_surface.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

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
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;

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
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 0),
            child: Row(
              children: [
                Icon(
                  shadcn.LucideIcons.slidersHorizontal,
                  size: 15,
                  color: cs.mutedForeground,
                ),
                const SizedBox(width: 6),
                Text(
                  '筛选与排序',
                  style: typo.small.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.foreground,
                  ),
                ),
                const Spacer(),
                if (filter.hasActiveFilters)
                  GestureDetector(
                    onTap: () => filter.clearAll(),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            shadcn.LucideIcons.x,
                            size: 12,
                            color: cs.mutedForeground,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '清除全部',
                            style: typo.xSmall.copyWith(
                              color: cs.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (onClose != null) ...[
                  const SizedBox(width: 8),
                  shadcn.IconButton.ghost(
                    onPressed: onClose,
                    icon: Icon(
                      shadcn.LucideIcons.panelTopClose,
                      size: 15,
                      color: cs.mutedForeground,
                    ),
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
              spacing: 8,
              runSpacing: 4,
              children:
                  [
                    SiteAvailabilityFilter.all,
                    SiteAvailabilityFilter.alive,
                    SiteAvailabilityFilter.dead,
                  ].map((value) {
                    final active = filter.availability == value;
                    return FilterChip(
                      label: Text(
                        _availabilityLabel(value),
                        style: const TextStyle(fontSize: 12),
                      ),
                      selected: active,
                      showCheckmark: false,
                      onSelected: (_) => filter.setAvailability(value),
                      selectedColor: cs.primary.withValues(alpha: 0.15),
                      side: BorderSide(
                        color: active
                            ? cs.primary
                            : cs.border.withValues(alpha: 0.5),
                      ),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: active ? cs.primary : cs.foreground,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
            ),
          ),

          // ── 条件筛选 ──
          _section(
            context,
            '条件筛选',
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children:
                  [
                    FilterCondition.all,
                    ...FilterCondition.values.where(
                      (c) =>
                          c != FilterCondition.all &&
                          c != FilterCondition.alive &&
                          c != FilterCondition.dead,
                    ),
                  ].map((c) {
                    return FilterChip(
                      label: Text(
                        _conditionLabel(c),
                        style: const TextStyle(fontSize: 12),
                      ),
                      selected: filter.condition == c,
                      showCheckmark: false,
                      onSelected: (_) => filter.setCondition(c),
                      selectedColor: cs.primary.withValues(alpha: 0.15),
                      side: BorderSide(
                        color: filter.condition == c
                            ? cs.primary
                            : cs.border.withValues(alpha: 0.5),
                      ),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: filter.condition == c
                            ? cs.primary
                            : cs.foreground,
                        fontWeight: filter.condition == c
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      visualDensity: VisualDensity.compact,
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
              spacing: 8,
              runSpacing: 4,
              children: SortField.values.map((f) {
                final active = filter.sortField == f;
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _sortFieldLabel(f),
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (active) ...[
                        const SizedBox(width: 3),
                        Icon(
                          filter.sortAscending
                              ? shadcn.LucideIcons.arrowUp
                              : shadcn.LucideIcons.arrowDown,
                          size: 11,
                          color: cs.primary,
                        ),
                      ],
                    ],
                  ),
                  selected: active,
                  showCheckmark: false,
                  onSelected: (_) => filter.setSortField(f),
                  selectedColor: cs.primary.withValues(alpha: 0.15),
                  side: BorderSide(
                    color: active
                        ? cs.primary
                        : cs.border.withValues(alpha: 0.5),
                  ),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: active ? cs.primary : cs.foreground,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  visualDensity: VisualDensity.compact,
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
                spacing: 8,
                runSpacing: 4,
                children: [
                  FilterChip(
                    label: const Text('全部', style: TextStyle(fontSize: 12)),
                    selected: filter.selectedSiteTypes.isEmpty,
                    showCheckmark: false,
                    onSelected: (_) => filter.clearSiteTypes(),
                    selectedColor: cs.primary.withValues(alpha: 0.15),
                    side: BorderSide(
                      color: filter.selectedSiteTypes.isEmpty
                          ? cs.primary
                          : cs.border.withValues(alpha: 0.5),
                    ),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: filter.selectedSiteTypes.isEmpty
                          ? cs.primary
                          : cs.foreground,
                      fontWeight: filter.selectedSiteTypes.isEmpty
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    visualDensity: VisualDensity.compact,
                  ),
                  ...siteTypes.map((type) {
                    final active = filter.selectedSiteTypes.contains(type);
                    return FilterChip(
                      label: Text(type, style: const TextStyle(fontSize: 12)),
                      selected: active,
                      showCheckmark: false,
                      onSelected: (_) => filter.toggleSiteType(type),
                      selectedColor: cs.primary.withValues(alpha: 0.15),
                      side: BorderSide(
                        color: active
                            ? cs.primary
                            : cs.border.withValues(alpha: 0.5),
                      ),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: active ? cs.primary : cs.foreground,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      visualDensity: VisualDensity.compact,
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
                spacing: 8,
                runSpacing: 4,
                children: [
                  FilterChip(
                    label: const Text('全部', style: TextStyle(fontSize: 12)),
                    selected: filter.selectedTags.isEmpty,
                    showCheckmark: false,
                    onSelected: (_) => filter.clearTags(),
                    selectedColor: cs.primary.withValues(alpha: 0.15),
                    side: BorderSide(
                      color: filter.selectedTags.isEmpty
                          ? cs.primary
                          : cs.border.withValues(alpha: 0.5),
                    ),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: filter.selectedTags.isEmpty
                          ? cs.primary
                          : cs.foreground,
                      fontWeight: filter.selectedTags.isEmpty
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    visualDensity: VisualDensity.compact,
                  ),
                  ...tags.map((tag) {
                    final active = filter.selectedTags.contains(tag);
                    return FilterChip(
                      label: Text(
                        '#$tag',
                        style: const TextStyle(fontSize: 12),
                      ),
                      selected: active,
                      showCheckmark: false,
                      onSelected: (_) => filter.toggleTag(tag),
                      selectedColor: cs.primary.withValues(alpha: 0.15),
                      side: BorderSide(
                        color: active
                            ? cs.primary
                            : cs.border.withValues(alpha: 0.5),
                      ),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: active ? cs.primary : cs.foreground,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      visualDensity: VisualDensity.compact,
                    );
                  }),
                ],
              ),
            ),

          const SizedBox(height: 12),
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
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final maxLabelWidth = (MediaQuery.sizeOf(context).width - 96).clamp(
      120.0,
      240.0,
    );

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        FilterChip(
          label: const Text('全部', style: TextStyle(fontSize: 12)),
          selected: selectedValue == null,
          showCheckmark: false,
          onSelected: (_) => clear(),
          selectedColor: cs.primary.withValues(alpha: 0.15),
          side: BorderSide(
            color: selectedValue == null
                ? cs.primary
                : cs.border.withValues(alpha: 0.5),
          ),
          labelStyle: TextStyle(
            fontSize: 12,
            color: selectedValue == null ? cs.primary : cs.foreground,
            fontWeight: selectedValue == null
                ? FontWeight.w600
                : FontWeight.w400,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 2),
          visualDensity: VisualDensity.compact,
        ),
        ...values.map((value) {
          final active =
              _normalizeIdentity(selectedValue) == _normalizeIdentity(value);
          return FilterChip(
            label: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxLabelWidth),
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            selected: active,
            showCheckmark: false,
            onSelected: (_) => select(value),
            selectedColor: cs.primary.withValues(alpha: 0.15),
            side: BorderSide(
              color: active ? cs.primary : cs.border.withValues(alpha: 0.5),
            ),
            labelStyle: TextStyle(
              fontSize: 12,
              color: active ? cs.primary : cs.foreground,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 2),
            visualDensity: VisualDensity.compact,
          );
        }),
      ],
    );
  }

  static String _normalizeIdentity(String? value) =>
      value?.trim().toLowerCase() ?? '';

  Widget _section(BuildContext context, String label, Widget child) {
    final theme = shadcn.Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.typography.xSmall.copyWith(
              color: theme.colorScheme.mutedForeground,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Material(type: MaterialType.transparency, child: child),
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
