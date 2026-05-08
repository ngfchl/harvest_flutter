import 'package:flutter/material.dart';
import 'package:harvest/core/http/api.dart';
import 'package:harvest/core/http/hooks.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

const _dashboardCacheClearItems = [
  _DashboardCacheClearItem('豆瓣缓存数据', '*douban*'),
  _DashboardCacheClearItem('TMDB缓存数据', '*tmdb_*'),
  _DashboardCacheClearItem('影视Token数据', 'tmdb_api_auth'),
  _DashboardCacheClearItem('RSS缓存数据', 'rss_data_list'),
  _DashboardCacheClearItem('单下载器缓存', 'repeat_info_hash_cache:*-*'),
  _DashboardCacheClearItem('站点删种缓存', 'repeat_404_cache:*-*'),
  _DashboardCacheClearItem('辅种错误缓存', 'repeat_error_cache:*-*'),
  _DashboardCacheClearItem('辅种成功缓存', 'repeat_success_cache:*-*'),
  _DashboardCacheClearItem('辅种数据缓存', 'repeat_info_hash_cache'),
  _DashboardCacheClearItem('站点配置缓存', 'website_list'),
  _DashboardCacheClearItem('我的站点缓存', 'my_site_list'),
  _DashboardCacheClearItem('首页数据缓存', 'dashboard_data_*'),
];

class _DashboardCacheClearItem {
  final String name;
  final String value;

  const _DashboardCacheClearItem(this.name, this.value);
}

void showDashboardCacheClearPopover(
  BuildContext anchorContext, {
  bool above = false,
}) {
  shadcn.showPopover<void>(
    context: anchorContext,
    alignment: above ? Alignment.bottomRight : Alignment.topRight,
    anchorAlignment: above ? Alignment.topRight : Alignment.bottomRight,
    offset: const Offset(0, 8),
    consumeOutsideTaps: false,
    handler: const shadcn.PopoverOverlayHandler(),
    builder: (context) => const DashboardCacheClearPopover(),
  );
}

class DashboardCacheClearPopover extends StatefulWidget {
  const DashboardCacheClearPopover({super.key});

  @override
  State<DashboardCacheClearPopover> createState() =>
      _DashboardCacheClearPopoverState();
}

class _DashboardCacheClearPopoverState
    extends State<DashboardCacheClearPopover> {
  String? _clearingKey;

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final width = (MediaQuery.sizeOf(context).width - 32)
        .clamp(280.0, 360.0)
        .toDouble();
    final maxHeight = (MediaQuery.sizeOf(context).height * 0.62)
        .clamp(320.0, 480.0)
        .toDouble();

    return shadcn.ModalContainer(
      padding: EdgeInsets.all(theme.density.baseContentPadding * theme.scaling),
      child: SizedBox(
        width: width,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  shadcn.LucideIcons.trash2,
                  size: theme.scaling * 18,
                  color: cs.primary,
                ),
                SizedBox(width: theme.density.baseGap * theme.scaling),
                Expanded(
                  child: Text(
                    '缓存清理',
                    style: theme.typography.large.copyWith(
                      color: cs.foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                shadcn.IconButton.ghost(
                  icon: Icon(
                    shadcn.LucideIcons.x,
                    size: theme.scaling * 16,
                    color: cs.mutedForeground,
                  ),
                  onPressed: () => shadcn.closeOverlay(context),
                ),
              ],
            ),
            SizedBox(height: theme.density.baseGap * theme.scaling * 0.5),
            Text(
              '选择要清理的缓存范围',
              style: theme.typography.xSmall.copyWith(
                color: cs.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: theme.density.baseGap * theme.scaling * 1.5),
            Flexible(
              child: shadcn.Card(
                filled: true,
                fillColor: cs.muted.withValues(alpha: 0.16),
                borderColor: cs.border.withValues(alpha: 0.24),
                padding: EdgeInsets.all(theme.density.baseGap * theme.scaling),
                child: SingleChildScrollView(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final spacing = theme.density.baseGap * theme.scaling;
                      final itemWidth = (constraints.maxWidth - spacing) / 2;
                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: [
                          for (final item in _dashboardCacheClearItems)
                            SizedBox(
                              width: itemWidth,
                              height: theme.scaling * 34,
                              child: _cacheButton(context, item),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _cacheButton(BuildContext context, _DashboardCacheClearItem item) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final clearing = _clearingKey == item.value;

    return SizedBox.expand(
      child: shadcn.Button.outline(
        onPressed: _clearingKey == null ? () => _clearCache(item) : null,
        leading: clearing
            ? shadcn.CircularProgressIndicator(size: theme.scaling * 14)
            : Icon(
                shadcn.LucideIcons.database,
                size: theme.scaling * 14,
                color: cs.primary,
              ),
        child: Text(
          item.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.typography.xSmall.copyWith(
            color: cs.foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> _clearCache(_DashboardCacheClearItem item) async {
    setState(() => _clearingKey = item.value);
    try {
      await fetchBasic(API.CLEAR_CACHE, queryParameters: {'key': item.value});
      Toast.success('${item.name}已清理');
    } catch (_) {
      Toast.error('${item.name}清理失败');
    } finally {
      if (mounted) setState(() => _clearingKey = null);
    }
  }
}
