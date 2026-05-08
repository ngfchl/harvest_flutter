import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../site/model/site_info.dart';
import '../../site/provider/site_provider.dart';
import '../model/search_settings.dart';

class SearchSettingsSheet extends ConsumerStatefulWidget {
  const SearchSettingsSheet({super.key});

  @override
  ConsumerState<SearchSettingsSheet> createState() =>
      _SearchSettingsSheetState();
}

class _SearchSettingsSheetState extends ConsumerState<SearchSettingsSheet> {
  late int _maxCount;
  late bool _sitesEnabled;
  late List<String> _storedSites;
  late List<String> _selectedSites;

  @override
  void initState() {
    super.initState();
    final settings = SearchSettings.load();
    _maxCount = settings.maxCount;
    _sitesEnabled = settings.sitesEnabled;
    _storedSites = List.from(settings.storedSites);
    _selectedSites = List.from(settings.sites);
  }

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final availableSites = _availableSearchSites();
    final availableSiteKeys = availableSites.map(_siteKey).toSet();
    final selectedCount = _selectedSites
        .where((site) => availableSiteKeys.contains(site))
        .length;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: cs.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '搜索设置',
                style: typo.normal.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  '完成',
                  style: typo.small.copyWith(color: cs.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '最大站点数',
                      style: typo.small.copyWith(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '从多少个站点搜索，默认 5，0 表示全部',
                      style: typo.xSmall.copyWith(
                        color: cs.mutedForeground,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildUnlimitedButton(),
                  const SizedBox(width: 8),
                  _buildStepper(),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Flexible(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.mutedForeground.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cs.border.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '指定站点',
                              style: typo.small.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _sitesEnabled
                                  ? '仅显示存活且可搜索的站点'
                                  : '已关闭，搜索时 sites 参数为空',
                              style: typo.xSmall.copyWith(
                                color: cs.mutedForeground,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _sitesEnabled ? '$selectedCount 个站点' : '关闭',
                        style: typo.xSmall.copyWith(color: cs.primary),
                      ),
                      const SizedBox(width: 10),
                      Switch(
                        value: _sitesEnabled,
                        onChanged: _setSitesEnabled,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: shadcn.LucideIcons.refreshCw,
                          label: '加载',
                          color: Colors.blue,
                          onPress: availableSites.isEmpty
                              ? null
                              : () => _loadStoredSites(availableSites),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildActionButton(
                          icon: shadcn.LucideIcons.checkCheck,
                          label: '全部',
                          color: Colors.green,
                          onPress: availableSites.isEmpty
                              ? null
                              : () => _selectAllSites(availableSites),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildActionButton(
                          icon: shadcn.LucideIcons.dices,
                          label: '随机',
                          color: Colors.orange,
                          onPress: availableSites.isEmpty
                              ? null
                              : () => _selectRandomSites(availableSites),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: availableSites.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            child: Center(
                              child: Text(
                                '没有可搜索的存活站点',
                                style: typo.small.copyWith(
                                  color: cs.mutedForeground,
                                ),
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            child: Wrap(
                              spacing: 7,
                              runSpacing: 7,
                              children: [
                                for (final site in availableSites)
                                  _buildSiteChip(site),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<SiteInfo> _availableSearchSites() {
    final sites = ref.watch(siteInfoListProvider).valueOrNull ?? [];
    final result = sites
        .where(
          (site) =>
              site.available &&
              site.searchTorrents &&
              site.site.trim().isNotEmpty,
        )
        .toList();
    result.sort((a, b) {
      final sort = a.sortId.compareTo(b.sortId);
      if (sort != 0) return sort;
      return _siteLabel(a).compareTo(_siteLabel(b));
    });
    return result;
  }

  Widget _buildStepper() {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: cs.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _maxCount > 0 ? () => _setMaxCount(_maxCount - 1) : null,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                shadcn.LucideIcons.minus,
                size: 16,
                color: _maxCount > 0
                    ? cs.foreground
                    : cs.mutedForeground.withValues(alpha: 0.3),
              ),
            ),
          ),
          Container(
            width: 34,
            alignment: Alignment.center,
            child: Text(
              _maxCount == 0 ? '全部' : '$_maxCount',
              style: typo.small.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          GestureDetector(
            onTap: () => _setMaxCount(_maxCount + 1),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                shadcn.LucideIcons.plus,
                size: 16,
                color: cs.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlimitedButton() {
    final typo = shadcn.Theme.of(context).typography;
    final active = _maxCount == 0;
    const color = Colors.teal;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: active ? null : () => _setMaxCount(0),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: active ? 0.16 : 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: active ? 0.65 : 0.38),
          ),
        ),
        child: Text(
          '不限',
          style: typo.xSmall.copyWith(
            color: active ? color : color.withValues(alpha: 0.82),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPress,
  }) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;
    final enabled = onPress != null;
    final effectiveColor = enabled ? color : cs.mutedForeground;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPress,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Container(
          height: 30,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: effectiveColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: effectiveColor.withValues(alpha: 0.45)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: effectiveColor),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typo.xSmall.copyWith(
                    color: effectiveColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSiteChip(SiteInfo site) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;
    final key = _siteKey(site);
    final selected = _selectedSites.contains(key);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _toggleSite(key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        constraints: const BoxConstraints(maxWidth: 150),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? cs.primary.withValues(alpha: 0.12)
              : cs.background.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: selected
                ? cs.primary.withValues(alpha: 0.55)
                : cs.border.withValues(alpha: 0.55),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                _siteLabel(site),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typo.xSmall.copyWith(
                  color: selected ? cs.primary : cs.foreground,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 5),
              Icon(shadcn.LucideIcons.check, size: 12, color: cs.primary),
            ],
          ],
        ),
      ),
    );
  }

  String _siteLabel(SiteInfo site) {
    final nickname = site.nickname.trim();
    return nickname.isNotEmpty ? nickname : site.site;
  }

  String _siteKey(SiteInfo site) => site.id.toString();

  void _setMaxCount(int value) {
    setState(() => _maxCount = value);
    _save();
  }

  void _setSitesEnabled(bool value) {
    setState(() {
      _sitesEnabled = value;
      if (!value) _selectedSites = <String>[];
    });
    _save();
  }

  void _toggleSite(String site) {
    setState(() {
      _sitesEnabled = true;
      if (_selectedSites.contains(site)) {
        _selectedSites.remove(site);
      } else {
        _selectedSites.add(site);
      }
      _storedSites = List.from(_selectedSites);
    });
    _save();
  }

  void _loadStoredSites(List<SiteInfo> availableSites) {
    final stored = _normalizeSiteKeys(_storedSites, availableSites);
    setState(() {
      _sitesEnabled = true;
      _selectedSites = stored;
      _storedSites = List.from(stored);
    });
    _save();
  }

  void _selectAllSites(List<SiteInfo> availableSites) {
    setState(() {
      _sitesEnabled = true;
      _selectedSites = availableSites.map(_siteKey).toList();
      _storedSites = List.from(_selectedSites);
    });
    _save();
  }

  void _selectRandomSites(List<SiteInfo> availableSites) {
    final count = _maxCount == 0
        ? availableSites.length
        : min(_maxCount, availableSites.length);
    final shuffled = List<SiteInfo>.from(availableSites)
      ..shuffle(Random.secure());
    setState(() {
      _sitesEnabled = true;
      _selectedSites = shuffled.take(count).map(_siteKey).toList();
      _storedSites = List.from(_selectedSites);
    });
    _save();
  }

  List<String> _normalizeSiteKeys(List<String> values, List<SiteInfo> sites) {
    final byId = {for (final site in sites) _siteKey(site): _siteKey(site)};
    final byName = {for (final site in sites) site.site: _siteKey(site)};
    final normalized = <String>[];
    for (final raw in values) {
      final value = raw.trim();
      final key = byId[value] ?? byName[value];
      if (key != null && !normalized.contains(key)) normalized.add(key);
    }
    return normalized;
  }

  void _save() {
    SearchSettings(
      maxCount: _maxCount,
      sites: _sitesEnabled ? _selectedSites : const [],
      storedSites: _storedSites,
      sitesEnabled: _sitesEnabled,
    ).save();
  }
}
