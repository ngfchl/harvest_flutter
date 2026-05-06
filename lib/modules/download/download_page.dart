import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:harvest/core/utils/utils.dart';

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
      ref.read(activeScrollControllerProvider.notifier).state =
          _scrollController;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(downloaderSpeedProvider);

    final asyncList = ref.watch(downloaderListProvider);
    final cs = FTheme.of(context).colors;
    final typo = FTheme.of(context).typography;
    final mobile = context.isMobile;
    final cacheInfo = ref.watch(downloaderListCacheInfoProvider);
    final refreshHeader = appRefreshHeader(context);

    return Stack(
      children: [
        asyncList.when(
          loading: () => Center(child: FProgress.circularIcon()),
          error: (e, _) =>
              _DownloaderErrorView(error: e, onRetry: _refreshDownloaders),
          data: (list) {
            if (list.isEmpty) {
              return Column(
                children: [
                  CacheStatusBanner(
                    info: cacheInfo,
                    margin: EdgeInsets.fromLTRB(
                      mobile ? 12 : 24,
                      8,
                      mobile ? 12 : 24,
                      6,
                    ),
                  ),
                  Expanded(
                    child: EasyRefresh(
                      onRefresh: _refreshDownloaders,
                      header: refreshHeader,
                      child: ListView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.only(
                          bottom: 16 + ShellBottomSpacing.value(context),
                        ),
                        children: [
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.28,
                          ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  FIcons.hardDrive,
                                  size: 48,
                                  color: cs.mutedForeground.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '暂无下载器',
                                  style: typo.lg.copyWith(
                                    color: cs.mutedForeground,
                                  ),
                                ),
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
                  margin: EdgeInsets.fromLTRB(
                    mobile ? 12 : 24,
                    8,
                    mobile ? 12 : 24,
                    2,
                  ),
                ),
                // ── 顶部状态栏 ──
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    mobile ? 12 : 24,
                    12,
                    mobile ? 12 : 24,
                    4,
                  ),
                  child: Consumer(
                    builder: (context, ref, _) {
                      final cs = FTheme.of(context).colors;
                      final paused = ref.watch(speedPausedProvider);
                      final remaining = ref.watch(speedRemainingProvider);

                      // 格式化倒计时
                      final min = remaining ~/ 60;
                      final sec = remaining % 60;
                      final countdown = remaining > 0
                          ? '$min:${sec.toString().padLeft(2, '0')}'
                          : '';

                      return Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: paused
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            paused ? '实时数据已暂停' : '实时数据接收中',
                            style: typo.xs.copyWith(
                              color: cs.mutedForeground.withValues(alpha: 0.5),
                              fontSize: 11,
                            ),
                          ),
                          // ── 倒计时 ──
                          if (!paused && remaining > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: remaining <= 60
                                    ? const Color(
                                        0xFFF59E0B,
                                      ).withValues(alpha: 0.1)
                                    : cs.foreground.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    FIcons.timer,
                                    size: 10,
                                    color: remaining <= 60
                                        ? const Color(0xFFF59E0B)
                                        : cs.mutedForeground.withValues(
                                            alpha: 0.5,
                                          ),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    countdown,
                                    style: typo.xs.copyWith(
                                      fontSize: 10,
                                      color: remaining <= 60
                                          ? const Color(0xFFF59E0B)
                                          : cs.mutedForeground.withValues(
                                              alpha: 0.5,
                                            ),
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const Spacer(),
                          // ── 设置齿轮 ──
                          GestureDetector(
                            onTap: () => showSpeedSettings(context, ref),
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                FIcons.settings,
                                size: 14,
                                color: cs.mutedForeground.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                          ),
                          // ── 暂停/恢复 ──
                          GestureDetector(
                            onTap: () {
                              ref.read(speedPausedProvider.notifier).state =
                                  !paused;
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: paused
                                    ? const Color(
                                        0xFF10B981,
                                      ).withValues(alpha: 0.1)
                                    : const Color(
                                        0xFFF59E0B,
                                      ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    paused ? FIcons.play : FIcons.pause,
                                    size: 12,
                                    color: paused
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFF59E0B),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    paused ? '恢复' : '暂停',
                                    style: typo.xs.copyWith(
                                      color: paused
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFF59E0B),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                // ── 列表 / 网格 ──
                Expanded(
                  child: EasyRefresh(
                    onRefresh: _refreshDownloaders,
                    header: refreshHeader,
                    child: mobile
                        ? _buildMobileList(list)
                        : _buildDesktopGrid(list),
                  ),
                ),
              ],
            );
          },
        ),
        Positioned(
          right: 16,
          bottom: 16 + ShellBottomSpacing.value(context),
          child: FButton.icon(
            onPress: () => _showEditor(),
            child: const Icon(FIcons.plus, size: 20),
          ),
        ),
      ],
    );
  }

  Future<void> _refreshDownloaders() async {
    await ref.read(downloaderListProvider.notifier).refresh();
    ref.invalidate(downloaderSpeedProvider);
  }

  // ── 手机端：单列列表 ──
  Widget _buildMobileList(List<Downloader> list) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      itemCount: list.length + 1,
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
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 220, // 固定高度
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
            SliverToBoxAdapter(
              child: SizedBox(height: 72 + ShellBottomSpacing.value(context)),
            ),
          ],
        );
      },
    );
  }

  void _showEditor({Downloader? downloader}) {
    showDialog(
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
    showDialog(
      context: context,
      builder: (ctx) => FDialog(
        title: const Text('删除下载器'),
        body: Text('确定删除「${d.name}」吗？此操作不可撤销。'),
        actions: [
          FButton(
            style: FButtonStyle.outline(),
            onPress: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          FButton(
            style: FButtonStyle.destructive(),
            onPress: () {
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
    ref
        .read(downloaderListProvider.notifier)
        .edit(d.copyWith(isActive: !d.isActive));
  }

  void _toggleBrush(Downloader d) {
    ref.read(downloaderListProvider.notifier).edit(d.copyWith(brush: !d.brush));
  }
}

class _DownloaderErrorView extends StatelessWidget {
  final Object error;
  final Future<void> Function() onRetry;

  const _DownloaderErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colors;
    final typo = context.theme.typography;

    return EasyRefresh(
      onRefresh: onRetry,
      header: appRefreshHeader(context),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          bottom: 16 + ShellBottomSpacing.value(context),
        ),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.28),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(FIcons.circleAlert, size: 44, color: cs.destructive),
                  const SizedBox(height: 12),
                  Text(
                    '下载器加载失败',
                    style: typo.lg.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$error',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: typo.xs.copyWith(color: cs.mutedForeground),
                  ),
                  const SizedBox(height: 16),
                  FButton(onPress: onRetry, child: const Text('重新加载')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
