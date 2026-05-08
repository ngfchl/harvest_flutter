import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../widgets/cache_status_banner.dart';
import '../shell/provider/screenshot_provider.dart';
import '../shell/widgets/shell_scaffold.dart';
import 'model/downloader.dart';
import 'provider/downloader_provider.dart';
import 'provider/downloader_speed_provider.dart';
import 'widgets/downloader_card.dart';
import 'widgets/downloader_editor_dialog.dart';
import 'widgets/downloader_speed_setting.dart';

class DownloaderPage extends ConsumerStatefulWidget {
  const DownloaderPage({super.key});

  @override
  ConsumerState<DownloaderPage> createState() => _DownloaderPageState();
}

class _DownloaderPageState extends ConsumerState<DownloaderPage> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(activeScrollControllerProvider.notifier).state = _scrollController;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(downloaderSpeedProvider);

    final asyncList = ref.watch(downloaderListProvider);
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;
    final mobile = context.isMobile;
    final cacheInfo = ref.watch(downloaderListCacheInfoProvider);
    final refreshHeader = appRefreshHeader(context);
    final tokens = _DownloaderPageTokens.of(context);
    final horizontalInset = mobile ? tokens.size(12) : tokens.size(24);

    return shadcn.Scaffold(
      backgroundColor: cs.background,
      child: Stack(
        children: [
          Positioned.fill(
            child: ColoredBox(
              color: cs.background,
              child: asyncList.when(
                loading: () => Center(child: shadcn.CircularProgressIndicator(strokeWidth: tokens.size(2))),
                error: (e, _) => _DownloaderErrorView(error: e, onRetry: _refreshDownloaders),
                data: (list) {
                  if (list.isEmpty) {
                    return Column(
                      children: [
                        CacheStatusBanner(
                          info: cacheInfo,
                          margin: EdgeInsets.fromLTRB(horizontalInset, tokens.size(8), horizontalInset, tokens.size(6)),
                        ),
                        _buildStatusBar(horizontalInset),
                        Expanded(
                          child: EasyRefresh(
                            onRefresh: _refreshDownloaders,
                            header: refreshHeader,
                            child: ListView(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.only(bottom: tokens.size(16) + ShellBottomSpacing.value(context)),
                              children: [
                                SizedBox(height: MediaQuery.sizeOf(context).height * 0.28),
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        shadcn.LucideIcons.hardDrive,
                                        size: tokens.font(48),
                                        color: cs.mutedForeground.withValues(alpha: 0.3),
                                      ),
                                      _DownloaderPageTokens.of(context).vGap(12),
                                      Text('暂无下载器', style: typo.large.copyWith(color: cs.mutedForeground)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      CacheStatusBanner(
                        info: cacheInfo,
                        margin: EdgeInsets.fromLTRB(horizontalInset, tokens.size(8), horizontalInset, tokens.size(2)),
                      ),
                      _buildStatusBar(horizontalInset),
                      // ── 列表 / 网格 ──
                      Expanded(
                        child: EasyRefresh(
                          onRefresh: _refreshDownloaders,
                          header: refreshHeader,
                          child: mobile ? _buildMobileList(list) : _buildDesktopGrid(list),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(double horizontalInset) {
    final theme = shadcn.Theme.of(context);
    final typo = theme.typography;
    final tokens = _DownloaderPageTokens.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalInset, tokens.size(12), horizontalInset, tokens.size(4)),
      child: Consumer(
        builder: (context, ref, _) {
          final cs = shadcn.Theme.of(context).colorScheme;
          final paused = ref.watch(speedPausedProvider);
          final remaining = ref.watch(speedRemainingProvider);

          final min = remaining ~/ 60;
          final sec = remaining % 60;
          final countdown = remaining > 0 ? '$min:${sec.toString().padLeft(2, '0')}' : '';

          return Row(
            children: [
              Icon(
                shadcn.LucideIcons.circle,
                size: tokens.iconXs,
                color: paused ? cs.destructive : cs.primary,
              ),
              tokens.hGap(6),
              Text(
                paused ? '实时数据已暂停' : '实时数据接收中',
                style: typo.xSmall.copyWith(color: cs.mutedForeground),
              ),
              if (!paused && remaining > 0) ...[
                tokens.hGap(8),
                shadcn.SecondaryBadge(
                  leading: Icon(shadcn.LucideIcons.timer, size: tokens.iconXs),
                  child: Text(countdown),
                ),
              ],
              const Spacer(),
              shadcn.IconButton.ghost(
                onPressed: () => showSpeedSettings(context, ref),
                icon: Icon(
                  shadcn.LucideIcons.settings,
                  size: tokens.iconLg,
                  color: cs.foreground,
                ),
              ),
              shadcn.IconButton.ghost(
                onPressed: () {
                  ref.read(speedPausedProvider.notifier).state = !paused;
                },
                icon: Icon(
                  paused ? shadcn.LucideIcons.play : shadcn.LucideIcons.pause,
                  size: tokens.iconLg,
                  color: cs.foreground,
                ),
              ),
              shadcn.IconButton.ghost(
                onPressed: () => _showEditor(),
                icon: Icon(
                  shadcn.LucideIcons.plus,
                  size: tokens.iconLg,
                  color: cs.foreground,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _refreshDownloaders() async {
    await ref.read(downloaderListProvider.notifier).refresh();
    ref.invalidate(downloaderSpeedProvider);
  }

  // ── 手机端：单列列表 ──
  Widget _buildMobileList(List<Downloader> list) {
    final tokens = _DownloaderPageTokens.of(context);
    return ListView.separated(
      controller: _scrollController,
      padding: tokens.edgeFromLTRB(12, 10, 12, 0),
      itemCount: list.length + 1,
      separatorBuilder: (context, i) => i >= list.length - 1 ? const SizedBox.shrink() : tokens.vGap(12),
      itemBuilder: (context, i) {
        if (i == list.length) {
          return SizedBox(height: 72 + ShellBottomSpacing.value(context));
        }
        return DownloaderCard(
          downloader: list[i],
          onEdit: () => _showEditor(downloader: list[i]),
          onDelete: () => _confirmDelete(list[i]),
          onToggleActive: () => _toggleActive(list[i]),
          onToggleBrush: () => _toggleBrush(list[i]),
        );
      },
    );
  }

  Widget _buildDesktopGrid(List<Downloader> list) {
    final tokens = _DownloaderPageTokens.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount;
        if (width > 1400) {
          crossAxisCount = 3;
        } else if (width > 900) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 1;
        }

        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPadding(
              padding: tokens.edgeFromLTRB(24, 8, 24, 0),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: tokens.size(12),
                  crossAxisSpacing: tokens.size(12),
                  mainAxisExtent: tokens.size(220),
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => DownloaderCard(
                    downloader: list[i],
                    onEdit: () => _showEditor(downloader: list[i]),
                    onDelete: () => _confirmDelete(list[i]),
                    onToggleActive: () => _toggleActive(list[i]),
                    onToggleBrush: () => _toggleBrush(list[i]),
                  ),
                  childCount: list.length,
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 72 + ShellBottomSpacing.value(context))),
          ],
        );
      },
    );
  }

  void _showEditor({Downloader? downloader}) {
    shadcn.showDialog(
      context: context,
      builder: (_) => DownloaderEditorDialog(
        downloader: downloader,
        onSaved: (d) {
          if (downloader == null) {
            ref.read(downloaderListProvider.notifier).add(d);
          } else {
            ref.read(downloaderListProvider.notifier).edit(d);
          }
        },
      ),
    );
  }

  void _confirmDelete(Downloader d) {
    shadcn.showDialog(
      context: context,
      builder: (ctx) => shadcn.AlertDialog(
        title: const Text('删除下载器'),
        content: Text('确定删除「${d.name}」吗？此操作不可撤销。'),
        actions: [
          shadcn.Button.outline(onPressed: () => Navigator.of(ctx).pop(), child: const Text('取消')),
          shadcn.Button.destructive(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(downloaderListProvider.notifier).remove(d.id);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _toggleActive(Downloader d) {
    ref.read(downloaderListProvider.notifier).edit(d.copyWith(isActive: !d.isActive));
  }

  void _toggleBrush(Downloader d) {
    ref.read(downloaderListProvider.notifier).edit(d.copyWith(brush: !d.brush));
  }
}

class _DownloaderPageTokens {
  final shadcn.ThemeData theme;
  final double densityScale;
  final double textScale;

  _DownloaderPageTokens._({required this.theme, required this.densityScale, required this.textScale});

  factory _DownloaderPageTokens.of(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final densityScale = ((theme.density.baseContentPadding / 16.0) * theme.scaling).clamp(0.55, 1.45);
    final textScale = theme.scaling.clamp(0.86, 1.30);
    return _DownloaderPageTokens._(
      theme: theme,
      densityScale: densityScale.toDouble(),
      textScale: textScale.toDouble(),
    );
  }

  double size(num value) => value * densityScale;

  double font(num value) => value * textScale;

  double get iconXs => font(12);

  double get iconSm => font(14);

  double get iconLg => font(20);

  EdgeInsets edgeFromLTRB(num left, num top, num right, num bottom) =>
      EdgeInsets.fromLTRB(size(left), size(top), size(right), size(bottom));

  SizedBox hGap(num value) => SizedBox(width: size(value));

  SizedBox vGap(num value) => SizedBox(height: size(value));
}

class _DownloaderErrorView extends StatelessWidget {
  final Object error;
  final Future<void> Function() onRetry;

  const _DownloaderErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;
    final tokens = _DownloaderPageTokens.of(context);

    return EasyRefresh(
      onRefresh: onRetry,
      header: appRefreshHeader(context),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: tokens.size(16) + ShellBottomSpacing.value(context)),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.28),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.size(24)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(shadcn.LucideIcons.circleAlert, size: tokens.font(44), color: cs.destructive),
                  tokens.vGap(12),
                  Text('下载器加载失败', style: typo.large.copyWith(fontWeight: FontWeight.w600)),
                  tokens.vGap(6),
                  Text(
                    '$error',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: typo.xSmall.copyWith(color: cs.mutedForeground),
                  ),
                  tokens.vGap(16),
                  shadcn.Button.primary(onPressed: onRetry, child: const Text('重新加载')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
