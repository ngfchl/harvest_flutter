import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/theme/app_surface.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/download/provider/downloader_provider.dart';
import 'package:harvest/modules/shell/widgets/global_drawer_swipe_area.dart';
import 'package:harvest/widgets/app_dialog.dart';
import 'package:harvest/widgets/escape_back_scope.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'model/rss_models.dart';
import 'provider/rss_provider.dart';
import 'widgets/qb_rss_manager.dart';
import 'widgets/rss_feed_sheet.dart';
import 'widgets/rss_plan_sheet.dart';
import 'widgets/rss_subscription_sheet.dart';
import 'widgets/rss_tag_sheet.dart';
import 'dart:async';
import 'package:harvest/widgets/app_header_layout.dart';
import 'package:harvest/widgets/shadcn_compat.dart';
import 'package:shadcn_flutter_material/shadcn_flutter_material.dart';

/// RSS 订阅管理页。
class RssPage extends ConsumerStatefulWidget {
  const RssPage({super.key});

  @override
  ConsumerState<RssPage> createState() => _RssPageState();
}

class _RssPageState extends ConsumerState<RssPage> {
  int _tabIndex = 0;

  static const _tabs = ['订阅', 'RSS 源', '订阅标签', '订阅方案', '订阅历史'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pageBackground = appSurfaceColor(context, cs.background);

    return EscapeBackScope(
      onBack: () => Navigator.of(context).pop(),
      child: GlobalDrawerSwipeArea(
        child: AppBackground(
          child: ColoredBox(
            color: pageBackground,
            child: Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: _RssHeader(
                    onBack: () => Navigator.of(context).pop(),
                    onRefresh: _refreshAll,
                  ),
                ),
                _RssTabBar(
                  index: _tabIndex,
                  tabs: _tabs,
                  onChanged: (i) => setState(() => _tabIndex = i),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _tabIndex,
                    children: const [
                      _SubscriptionsTab(),
                      _FeedsTab(),
                      _TagsTab(),
                      _PlansTab(),
                      _HistoryTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      ref.read(rssSubscriptionsProvider.notifier).refresh(),
      ref.read(rssFeedsProvider.notifier).refresh(),
      ref.read(rssTagsProvider.notifier).refresh(),
      ref.read(rssPlansProvider.notifier).refresh(),
      ref.read(rssHistoryProvider.notifier).refresh(),
    ]);
  }
}

// ─────────────────── 头部 ───────────────────

class _RssHeader extends ConsumerWidget {
  final VoidCallback onBack;
  final VoidCallback onRefresh;

  const _RssHeader({required this.onBack, required this.onRefresh});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final subsAsync = ref.watch(rssSubscriptionsProvider);
    final subs = subsAsync.value ?? const <RssSubscription>[];
    final enabledCount = subs.where((s) => s.enabled).length;

    return Container(
      padding: appHeaderPadding(context, left: 12, right: 8),
      decoration: BoxDecoration(
        color: appSurfaceColor(context, cs.background),
        border: Border(bottom: BorderSide(color: cs.border, width: 0.5)),
      ),
      child: Row(
        children: [
          IconButton.ghost(
            onPressed: onBack,
            icon: const Icon(LucideIcons.arrowLeft, size: 18),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RSS 订阅',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  subsAsync.isLoading
                      ? '加载中...'
                      : '共 ${subs.length} 个订阅 · 启用 $enabledCount 个',
                  style: TextStyle(fontSize: 11, color: cs.mutedForeground),
                ),
              ],
            ),
          ),
          Button.outline(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const QbRssManagerPage()),
            ),
            child: const Text('下载器 RSS'),
          ),
          const SizedBox(width: 8),
          IconButton.ghost(
            onPressed: onRefresh,
            icon: const Icon(LucideIcons.refreshCw, size: 16),
          ),
          const SizedBox(width: 4),
          _RunAllButton(),
        ],
      ),
    );
  }
}

class _RunAllButton extends ConsumerStatefulWidget {
  @override
  ConsumerState<_RunAllButton> createState() => _RunAllButtonState();
}

class _RunAllButtonState extends ConsumerState<_RunAllButton> {
  bool _running = false;

  Future<void> _run() async {
    if (_running) return;
    setState(() => _running = true);
    try {
      final results = await ref.read(rssSubscriptionsProvider.notifier).runAll();
      if (!mounted) return;
      final pushed = results.where((r) => r.pushed).length;
      Toast.success('执行完成：$pushed/${results.length} 条已推送');
    } catch (_) {
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Button.primary(
      onPressed: _running ? null : _run,
      child: _running
          ? const SizedBox(
              width: 16,
              height: 16,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          : const Text('执行订阅'),
    );
  }
}

// ─────────────────── Tab Bar ───────────────────

class _RssTabBar extends StatelessWidget {
  final int index;
  final List<String> tabs;
  final ValueChanged<int> onChanged;

  const _RssTabBar({required this.index, required this.tabs, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: BoxDecoration(
        color: appSurfaceColor(context, cs.background),
        border: Border(bottom: BorderSide(color: cs.border, width: 0.5)),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Tabs(
          index: index,
          onChanged: onChanged,
          children: [for (final t in tabs) TabItem(child: Text(t))],
        ),
      ),
    );
  }
}

// ─────────────────── 订阅列表 ───────────────────

class _SubscriptionsTab extends ConsumerWidget {
  const _SubscriptionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(rssSubscriptionsProvider);
    return EasyRefresh(
      onRefresh: () => ref.read(rssSubscriptionsProvider.notifier).refresh(),
      header: appRefreshHeader(context),
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (e, _) => _RssErrorView(
          error: e,
          onRetry: () => ref.read(rssSubscriptionsProvider.notifier).refresh(),
        ),
        data: (subs) => _SubscriptionsList(subs: subs),
      ),
    );
  }
}

class _SubscriptionsList extends ConsumerWidget {
  final List<RssSubscription> subs;

  const _SubscriptionsList({required this.subs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final plans = ref.watch(rssPlansProvider).value ?? const <RssPlan>[];
    final mobile = context.isMobile;

    return ListView(
      padding: EdgeInsets.fromLTRB(mobile ? 12 : 16, 12, mobile ? 12 : 16, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '订阅 ${subs.length} 个',
                style: TextStyle(fontSize: 12, color: cs.mutedForeground),
              ),
            ),
            Button.outline(
              onPressed: () => showRssSubscriptionSheet(context),
              child: const Text('添加订阅'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (subs.isEmpty)
          _RssEmptyView(
            icon: LucideIcons.rss,
            title: '暂无订阅',
            subtitle: '添加订阅后，系统会按关键字与方案自动筛选并推送种子',
            actionLabel: '添加订阅',
            onAction: () => showRssSubscriptionSheet(context),
          )
        else
          for (final sub in subs) ...[
            _SubscriptionCard(
              sub: sub,
              planName: plans
                  .where((p) => p.id == sub.planId)
                  .fold<String?>(null, (_, p) => p.name),
            ),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}

class _SubscriptionCard extends ConsumerWidget {
  final RssSubscription sub;
  final String? planName;

  const _SubscriptionCard({required this.sub, this.planName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return AppSurfaceContainer(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.rss,
                size: 16,
                color: sub.enabled ? cs.primary : cs.mutedForeground,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  sub.name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
              Switch(
                value: sub.enabled,
                onChanged: (v) async {
                  await ref.read(rssSubscriptionsProvider.notifier).save(
                        RssSubscription(
                          id: sub.id,
                          name: sub.name,
                          enabled: v,
                          keyword: sub.keyword,
                          excludes: sub.excludes,
                          season: sub.season,
                          publishYear: sub.publishYear,
                          doubanId: sub.doubanId,
                          imdbId: sub.imdbId,
                          tmdbId: sub.tmdbId,
                          planId: sub.planId,
                        ),
                      );
                },
              ),
              IconButton.ghost(
                onPressed: () => _showMenu(context, ref),
                icon: const Icon(LucideIcons.ellipsis, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _MetaRow(label: '关键字', value: sub.keyword.isEmpty ? '（全部）' : sub.keyword),
          if (planName != null) _MetaRow(label: '方案', value: planName!),
          if (sub.season.isNotEmpty) _MetaRow(label: '季数', value: sub.season),
          if (sub.excludes.isNotEmpty)
            _MetaRow(label: '排除', value: sub.excludes.join('、')),
          if (sub.doubanId.isNotEmpty ||
              sub.imdbId.isNotEmpty ||
              sub.tmdbId.isNotEmpty)
            _MetaRow(
              label: '媒体 ID',
              value: [
                if (sub.doubanId.isNotEmpty) '豆瓣 ${sub.doubanId}',
                if (sub.imdbId.isNotEmpty) 'IMDb ${sub.imdbId}',
                if (sub.tmdbId.isNotEmpty) 'TMDB ${sub.tmdbId}',
              ].join(' · '),
            ),
        ],
      ),
    );
  }

  void _showMenu(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    showPopover<void>(
      context: context,
      alignment: Alignment.bottomRight,
      anchorAlignment: Alignment.topRight,
      offset: const Offset(0, 4),
      consumeOutsideTaps: false,
      builder: (_) => DropdownMenu(
        children: [
          MenuButton(
            leading: const Icon(LucideIcons.play, size: 16),
            onPressed: (ctx) async {
              unawaited(closeOverlay(ctx));
              try {
                final r = await ref
                    .read(rssSubscriptionsProvider.notifier)
                    .runOne(sub.id);
                if (r.pushed) {
                  Toast.success('已推送：${r.title}');
                } else {
                  Toast.info(r.message.isEmpty ? '本次执行未推送新种子' : r.message);
                }
              } catch (_) {}
            },
            child: const Text('立即执行'),
          ),
          MenuButton(
            leading: const Icon(LucideIcons.eye, size: 16),
            onPressed: (ctx) async {
              unawaited(closeOverlay(ctx));
              try {
                final items = await ref
                    .read(rssSubscriptionsProvider.notifier)
                    .preview(sub.id);
                if (!context.mounted) return;
                _showPreviewDialog(context, items);
              } catch (_) {}
            },
            child: const Text('预览匹配'),
          ),
          MenuButton(
            leading: const Icon(LucideIcons.pencil, size: 16),
            onPressed: (ctx) {
              unawaited(closeOverlay(ctx));
              showRssSubscriptionSheet(context, subscription: sub);
            },
            child: const Text('编辑'),
          ),
          const MenuDivider(),
          MenuButton(
            leading: Icon(LucideIcons.trash2, size: 16, color: cs.destructive),
            onPressed: (ctx) {
              unawaited(closeOverlay(ctx));
              _confirmDelete(context, ref);
            },
            child: Text('删除', style: TextStyle(color: cs.destructive)),
          ),
        ],
      ),
    );
  }

  void _showPreviewDialog(BuildContext context, List<RssSubscriptionPreviewItem> items) {
    appShowDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('预览匹配 · ${items.length} 条'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 480),
          child: items.isEmpty
              ? Center(
                  child: Text(
                    '当前没有匹配到可推送的种子',
                    style: TextStyle(color: Theme.of(ctx).colorScheme.mutedForeground),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final it = items[i];
                    final cs = Theme.of(ctx).colorScheme;
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cs.muted.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: cs.border.withValues(alpha: 0.5), width: 0.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            it.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (it.feedName.isNotEmpty) ...[
                                Icon(LucideIcons.rss, size: 12, color: cs.mutedForeground),
                                const SizedBox(width: 4),
                                Text(it.feedName, style: TextStyle(fontSize: 11, color: cs.mutedForeground)),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                _formatSize(it.size),
                                style: TextStyle(fontSize: 11, color: cs.mutedForeground),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        actions: [
          Button.outline(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  static String _formatSize(int bytes) {
    if (bytes <= 0) return '未知大小';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var size = bytes.toDouble();
    var unit = 0;
    while (size >= 1024 && unit < units.length - 1) {
      size /= 1024;
      unit++;
    }
    return '${size.toStringAsFixed(1)} ${units[unit]}';
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    appShowDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除订阅「${sub.name}」吗？'),
        actions: [
          Button.outline(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          Button.destructive(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref.read(rssSubscriptionsProvider.notifier).delete(sub.id);
                Toast.success('订阅已删除');
              } catch (_) {}
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: cs.mutedForeground),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────── RSS 源列表 ───────────────────

class _FeedsTab extends ConsumerWidget {
  const _FeedsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(rssFeedsProvider);
    return EasyRefresh(
      onRefresh: () => ref.read(rssFeedsProvider.notifier).refresh(),
      header: appRefreshHeader(context),
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (e, _) => _RssErrorView(
          error: e,
          onRetry: () => ref.read(rssFeedsProvider.notifier).refresh(),
        ),
        data: (feeds) => _FeedsList(feeds: feeds),
      ),
    );
  }
}

class _FeedsList extends ConsumerWidget {
  final List<RssFeed> feeds;

  const _FeedsList({required this.feeds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final mobile = context.isMobile;

    return ListView(
      padding: EdgeInsets.fromLTRB(mobile ? 12 : 16, 12, mobile ? 12 : 16, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'RSS 源 ${feeds.length} 个',
                style: TextStyle(fontSize: 12, color: cs.mutedForeground),
              ),
            ),
            Button.outline(
              onPressed: () => showRssFeedSheet(context),
              child: const Text('添加源'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (feeds.isEmpty)
          _RssEmptyView(
            icon: LucideIcons.link,
            title: '暂无 RSS 源',
            subtitle: '添加 RSS 地址后，订阅方案才能拉取并筛选种子',
            actionLabel: '添加源',
            onAction: () => showRssFeedSheet(context),
          )
        else
          for (final feed in feeds) ...[
            _FeedCard(feed: feed),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}

class _FeedCard extends ConsumerWidget {
  final RssFeed feed;

  const _FeedCard({required this.feed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return AppSurfaceContainer(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.link,
                size: 16,
                color: feed.available ? cs.primary : cs.mutedForeground,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  feed.name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton.ghost(
                onPressed: () => _showMenu(context, ref),
                icon: const Icon(LucideIcons.ellipsis, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            feed.rss,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: cs.mutedForeground),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _FeedChip(text: '优先级 ${feed.sort}'),
              if (feed.siteId > 0) _FeedChip(text: '站点 #${feed.siteId}'),
              _FeedChip(
                text: feed.available ? '启用' : '停用',
                active: feed.available,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMenu(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    showPopover<void>(
      context: context,
      alignment: Alignment.bottomRight,
      anchorAlignment: Alignment.topRight,
      offset: const Offset(0, 4),
      consumeOutsideTaps: false,
      builder: (_) => DropdownMenu(
        children: [
          MenuButton(
            leading: const Icon(LucideIcons.pencil, size: 16),
            onPressed: (ctx) {
              unawaited(closeOverlay(ctx));
              showRssFeedSheet(context, feed: feed);
            },
            child: const Text('编辑'),
          ),
          MenuButton(
            leading: const Icon(LucideIcons.refreshCw, size: 16),
            onPressed: (ctx) async {
              unawaited(closeOverlay(ctx));
              try {
                final r = await ref.read(rssFeedsProvider.notifier).refreshFeed(feed.id);
                Toast.success('已刷新：${r.itemCount} 条');
              } catch (_) {}
            },
            child: const Text('刷新'),
          ),
          MenuButton(
            leading: Icon(
              feed.available ? LucideIcons.circlePause : LucideIcons.circlePlay,
              size: 16,
            ),
            onPressed: (ctx) async {
              unawaited(closeOverlay(ctx));
              try {
                await ref.read(rssFeedsProvider.notifier).save(
                      RssFeed(
                        id: feed.id,
                        name: feed.name,
                        rss: feed.rss,
                        sort: feed.sort,
                        available: !feed.available,
                        siteId: feed.siteId,
                      ),
                    );
              } catch (_) {}
            },
            child: Text(feed.available ? '停用' : '启用'),
          ),
          const MenuDivider(),
          MenuButton(
            leading: Icon(LucideIcons.trash2, size: 16, color: cs.destructive),
            onPressed: (ctx) {
              unawaited(closeOverlay(ctx));
              _confirmDelete(context, ref);
            },
            child: Text('删除', style: TextStyle(color: cs.destructive)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    appShowDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 RSS 源「${feed.name}」吗？'),
        actions: [
          Button.outline(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          Button.destructive(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref.read(rssFeedsProvider.notifier).delete(feed.id);
                Toast.success('RSS 源已删除');
              } catch (_) {}
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

class _FeedChip extends StatelessWidget {
  final String text;
  final bool active;

  const _FeedChip({required this.text, this.active = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: active
            ? cs.primary.withValues(alpha: 0.12)
            : cs.muted.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: active ? cs.primary.withValues(alpha: 0.3) : cs.border,
          width: 0.5,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: active ? cs.primary : cs.mutedForeground,
        ),
      ),
    );
  }
}

// ─────────────────── 标签列表 ───────────────────

class _TagsTab extends ConsumerWidget {
  const _TagsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(rssTagsProvider);
    return EasyRefresh(
      onRefresh: () => ref.read(rssTagsProvider.notifier).refresh(),
      header: appRefreshHeader(context),
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (e, _) => _RssErrorView(
          error: e,
          onRetry: () => ref.read(rssTagsProvider.notifier).refresh(),
        ),
        data: (tags) => _TagsList(tags: tags),
      ),
    );
  }
}

class _TagsList extends ConsumerStatefulWidget {
  final List<RssTag> tags;

  const _TagsList({required this.tags});

  @override
  ConsumerState<_TagsList> createState() => _TagsListState();
}

class _TagsListState extends ConsumerState<_TagsList> {
  bool _importing = false;

  Future<void> _importDefaults() async {
    if (_importing) return;
    final ok = await appShowDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('导入默认标签'),
        content: const Text('将导入内置的 Harvest 订阅标签字典，已存在的标签会被更新。确定继续吗？'),
        actions: [
          Button.outline(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('取消')),
          Button.primary(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('导入')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _importing = true);
    try {
      final r = await ref.read(rssTagsProvider.notifier).importDefaults();
      if (!mounted) return;
      Toast.success('导入完成：共 ${r.total} 个，新增 ${r.created} 个，更新 ${r.updated} 个');
    } catch (_) {
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mobile = context.isMobile;
    final tags = widget.tags;

    return ListView(
      padding: EdgeInsets.fromLTRB(mobile ? 12 : 16, 12, mobile ? 12 : 16, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '订阅标签 ${tags.length} 个',
                style: TextStyle(fontSize: 12, color: cs.mutedForeground),
              ),
            ),
            Button.outline(
              onPressed: _importing ? null : _importDefaults,
              child: _importing
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : const Text('导入默认'),
            ),
            const SizedBox(width: 8),
            Button.outline(
              onPressed: () => showRssTagSheet(context),
              child: const Text('添加标签'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (tags.isEmpty)
          _RssEmptyView(
            icon: LucideIcons.tags,
            title: '暂无订阅标签',
            subtitle: '标签用于对订阅条目做归类，例如分辨率、来源等。可先导入内置默认标签。',
            actionLabel: '导入默认标签',
            onAction: _importDefaults,
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final tag in tags) _TagChip(tag: tag)],
          ),
      ],
    );
  }
}

class _TagChip extends ConsumerWidget {
  final RssTag tag;

  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => showRssTagSheet(context, tag: tag),
      onLongPress: () => _confirmDelete(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: tag.enabled
              ? cs.primary.withValues(alpha: 0.10)
              : cs.muted.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: tag.enabled
                ? cs.primary.withValues(alpha: 0.28)
                : cs.border,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tag.name,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: tag.enabled ? cs.foreground : cs.mutedForeground,
              ),
            ),
            if (tag.category.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                rssTagCategoryLabel(tag.category),
                style: TextStyle(fontSize: 11, color: cs.mutedForeground),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    appShowDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除标签「${tag.name}」吗？'),
        actions: [
          Button.outline(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          Button.destructive(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref.read(rssTagsProvider.notifier).delete(tag.id);
                Toast.success('标签已删除');
              } catch (_) {}
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────── 方案列表 ───────────────────

class _PlansTab extends ConsumerWidget {
  const _PlansTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(rssPlansProvider);
    return EasyRefresh(
      onRefresh: () => ref.read(rssPlansProvider.notifier).refresh(),
      header: appRefreshHeader(context),
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (e, _) => _RssErrorView(
          error: e,
          onRetry: () => ref.read(rssPlansProvider.notifier).refresh(),
        ),
        data: (plans) => _PlansList(plans: plans),
      ),
    );
  }
}

class _PlansList extends ConsumerWidget {
  final List<RssPlan> plans;

  const _PlansList({required this.plans});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final mobile = context.isMobile;

    return ListView(
      padding: EdgeInsets.fromLTRB(mobile ? 12 : 16, 12, mobile ? 12 : 16, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '订阅方案 ${plans.length} 个',
                style: TextStyle(fontSize: 12, color: cs.mutedForeground),
              ),
            ),
            Button.outline(
              onPressed: () => showRssPlanSheet(context),
              child: const Text('添加方案'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (plans.isEmpty)
          _RssEmptyView(
            icon: LucideIcons.workflow,
            title: '暂无订阅方案',
            subtitle: '方案定义了大小、编码、下载器等筛选与推送规则',
            actionLabel: '添加方案',
            onAction: () => showRssPlanSheet(context),
          )
        else
          for (final plan in plans) ...[
            _PlanCard(plan: plan),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}

class _PlanCard extends ConsumerWidget {
  final RssPlan plan;

  const _PlanCard({required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final downloaders = ref.watch(downloaderListProvider).value ?? const [];
    final downloaderName = downloaders
        .where((d) => d.id == plan.downloaderId)
        .fold<String?>(null, (_, d) => d.name);

    return AppSurfaceContainer(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.workflow,
                size: 16,
                color: plan.enabled ? cs.primary : cs.mutedForeground,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  plan.name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton.ghost(
                onPressed: () => _showMenu(context, ref),
                icon: const Icon(LucideIcons.ellipsis, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _FeedChip(text: '${plan.minSizeMb}~${plan.maxSizeMb} MB'),
              if (downloaderName != null) _FeedChip(text: downloaderName),
              if (plan.rssFeedIds.isNotEmpty)
                _FeedChip(text: '${plan.rssFeedIds.length} 个源'),
              if (plan.resolution.isNotEmpty)
                _FeedChip(text: plan.resolution.join('/')),
              if (plan.videoCodec.isNotEmpty)
                _FeedChip(text: plan.videoCodec.join('/')),
              if (plan.excludes.isNotEmpty)
                _FeedChip(text: '排除 ${plan.excludes.length} 项'),
              _FeedChip(text: plan.enabled ? '启用' : '停用', active: plan.enabled),
            ],
          ),
        ],
      ),
    );
  }

  void _showMenu(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    showPopover<void>(
      context: context,
      alignment: Alignment.bottomRight,
      anchorAlignment: Alignment.topRight,
      offset: const Offset(0, 4),
      consumeOutsideTaps: false,
      builder: (_) => DropdownMenu(
        children: [
          MenuButton(
            leading: const Icon(LucideIcons.pencil, size: 16),
            onPressed: (ctx) {
              unawaited(closeOverlay(ctx));
              showRssPlanSheet(context, plan: plan);
            },
            child: const Text('编辑'),
          ),
          const MenuDivider(),
          MenuButton(
            leading: Icon(LucideIcons.trash2, size: 16, color: cs.destructive),
            onPressed: (ctx) {
              unawaited(closeOverlay(ctx));
              _confirmDelete(context, ref);
            },
            child: Text('删除', style: TextStyle(color: cs.destructive)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    appShowDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除方案「${plan.name}」吗？'),
        actions: [
          Button.outline(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          Button.destructive(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref.read(rssPlansProvider.notifier).delete(plan.id);
                Toast.success('方案已删除');
              } catch (_) {}
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────── 历史列表 ───────────────────

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(rssHistoryProvider);
    return EasyRefresh(
      onRefresh: () => ref.read(rssHistoryProvider.notifier).refresh(),
      header: appRefreshHeader(context),
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (e, _) => _RssErrorView(
          error: e,
          onRetry: () => ref.read(rssHistoryProvider.notifier).refresh(),
        ),
        data: (history) => _HistoryList(history: history),
      ),
    );
  }
}

class _HistoryList extends ConsumerWidget {
  final List<RssHistoryItem> history;

  const _HistoryList({required this.history});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final mobile = context.isMobile;

    return ListView(
      padding: EdgeInsets.fromLTRB(mobile ? 12 : 16, 12, mobile ? 12 : 16, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '推送历史 ${history.length} 条',
                style: TextStyle(fontSize: 12, color: cs.mutedForeground),
              ),
            ),
            if (history.isNotEmpty)
              Button.outline(
                onPressed: () => _confirmClear(context, ref),
                child: const Text('清空'),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (history.isEmpty)
          _RssEmptyView(
            icon: LucideIcons.history,
            title: '暂无推送历史',
            subtitle: '执行订阅后，推送记录会显示在这里',
          )
        else
          for (final item in history) ...[
            _HistoryCard(item: item),
            const SizedBox(height: 8),
          ],
      ],
    );
  }

  void _confirmClear(BuildContext context, WidgetRef ref) {
    appShowDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认清空'),
        content: const Text('确定要清空全部推送历史吗？'),
        actions: [
          Button.outline(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          Button.destructive(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref.read(rssHistoryProvider.notifier).clear();
                Toast.success('历史已清空');
              } catch (_) {}
            },
            child: const Text('清空'),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends ConsumerWidget {
  final RssHistoryItem item;

  const _HistoryCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return AppSurfaceContainer(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.title.isEmpty ? '（无标题）' : item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              if (item.pushed)
                PrimaryBadge(child: const Text('已推送'))
              else
                OutlineBadge(child: const Text('未推送')),
            ],
          ),
          const SizedBox(height: 6),
          _MetaRow(
            label: '订阅',
            value: item.subscriptionName.isEmpty
                ? '#${item.subscriptionId}'
                : item.subscriptionName,
          ),
          if (item.feedName.isNotEmpty) _MetaRow(label: '来源', value: item.feedName),
          if (item.message.isNotEmpty)
            _MetaRow(
              label: '备注',
              value: item.message,
            ),
          if (item.createdAt.isNotEmpty)
            _MetaRow(label: '时间', value: item.createdAt),
          const SizedBox(height: 6),
          Row(
            children: [
              if (!item.pushed && item.torrentUrl.isNotEmpty)
                Button.outline(
                  onPressed: () async {
                    try {
                      await ref
                          .read(rssHistoryProvider.notifier)
                          .push(item.id);
                      Toast.success('已重新推送');
                    } catch (_) {}
                  },
                  child: const Text('手动推送'),
                ),
              const Spacer(),
              IconButton.ghost(
                onPressed: () => _confirmDelete(context, ref),
                icon: Icon(LucideIcons.trash2, size: 15, color: cs.destructive),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    appShowDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条历史记录吗？'),
        actions: [
          Button.outline(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          Button.destructive(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref.read(rssHistoryProvider.notifier).delete(item.id);
                Toast.success('历史已删除');
              } catch (_) {}
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────── 空态 / 错误态 ───────────────────

class _RssEmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _RssEmptyView({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Icon(icon, size: 40, color: cs.mutedForeground.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: cs.mutedForeground),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            Button.primary(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class _RssErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _RssErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.circleAlert, size: 36, color: cs.destructive),
            const SizedBox(height: 12),
            Text(
              '加载失败',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: cs.mutedForeground),
            ),
            const SizedBox(height: 16),
            Button.primary(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      ),
    );
  }
}

