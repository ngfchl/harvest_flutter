import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:harvest/core/utils/utils.dart';

import '../../../search/model/search_mode.dart';
import '../../../search/unified_search_page.dart';
import '../model/video_detail.dart';
import '../service/douban_service.dart';

void openDoubanDetail(BuildContext context, String subjectId) {
  AppLogger.debug('Open Douban detail: $subjectId');
  if (subjectId.startsWith('https://')) {
    subjectId = extractDoubanId(subjectId);
  }
  if (context.isMobile) {
    showFSheet(
      context: context,
      side: FLayout.btt,
      mainAxisMaxRatio: 1.1,
      style: FSheetStyle(flingVelocity: 700, closeProgressThreshold: 0.5).call,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.75,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollCtrl) =>
            _DoubanDetailSheet(subjectId: subjectId),
      ),
    );
  } else {
    showFDialog(
      context: context,
      builder: (context, _, __) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 700),
          child: _DoubanDetailSheet(subjectId: subjectId),
        ),
      ),
    );
  }
}

String extractDoubanId(String url) {
  final regex = RegExp(r'/subject/(\d+)/');
  final match = regex.firstMatch(url);
  if (match != null) {
    return match.group(1)!; // 提取第一个分组，也就是id
  }
  return '';
}

class _DoubanDetailSheet extends ConsumerStatefulWidget {
  final String subjectId;

  const _DoubanDetailSheet({required this.subjectId});

  @override
  ConsumerState<_DoubanDetailSheet> createState() => _DoubanDetailSheetState();
}

class _DoubanDetailSheetState extends ConsumerState<_DoubanDetailSheet> {
  VideoDetail? _detail;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await DoubanService.getSubject(widget.subjectId);
      if (mounted) {
        setState(() {
          _detail = d;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _detail?.title ?? '详情';

    final Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null || _detail == null) {
      body = Center(child: Text('加载失败: $_error'));
    } else {
      body = _buildContent(context, _detail!);
    }

    return FScaffold(
      childPad: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部栏
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    child: Icon(FIcons.arrowLeft, size: 20),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.theme.typography.base.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          FDivider(
            style: FDividerStyle(
              color: context.theme.colors.border,
              padding: const EdgeInsets.symmetric(vertical: 6),
            ).call,
          ),
          // 内容
          Flexible(child: body),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, VideoDetail detail) {
    final hasRating = detail.rating.value > 0;
    final ratingText = hasRating ? detail.rating.value.toStringAsFixed(1) : '';
    final searchQuery = detail.title;

    return Column(
      children: [
        // ── 固定顶部海报 ──
        _buildBackdrop(context, detail.coverUrl),

        // ── 可滚动内容 ──
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              // 海报 + 基本信息
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPoster(context, detail.coverUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          detail.title,
                          style: context.theme.typography.lg.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (detail.originalTitle.isNotEmpty &&
                            detail.originalTitle != detail.title) ...[
                          const SizedBox(height: 2),
                          Text(
                            detail.originalTitle,
                            style: context.theme.typography.xs.copyWith(
                              color: context.theme.colors.mutedForeground
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                        if (detail.year.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            detail.year,
                            style: context.theme.typography.sm.copyWith(
                              color: context.theme.colors.mutedForeground,
                            ),
                          ),
                        ],
                        if (detail.genres.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: detail.genres
                                .map(
                                  (g) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.theme.colors.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      g,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: context.theme.colors.primary,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                        const SizedBox(height: 8),
                        if (hasRating)
                          Row(
                            children: [
                              Icon(FIcons.star, size: 16, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                ratingText,
                                style: context.theme.typography.base.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${detail.rating.count})',
                                style: context.theme.typography.xs.copyWith(
                                  color: context.theme.colors.mutedForeground,
                                ),
                              ),
                            ],
                          )
                        else if (detail.nullRatingReason.isNotEmpty)
                          Text(
                            detail.nullRatingReason,
                            style: context.theme.typography.xs.copyWith(
                              color: context.theme.colors.mutedForeground,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        if (detail.realtimeHonorInfos.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          ...detail.realtimeHonorInfos.map(
                            (h) => Container(
                              margin: const EdgeInsets.only(bottom: 2),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  '${h.title} #${h.rank}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              // 简介
              if (detail.intro.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '简介',
                  style: context.theme.typography.sm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  detail.intro,
                  style: context.theme.typography.sm.copyWith(
                    color: context.theme.colors.mutedForeground,
                    height: 1.5,
                  ),
                ),
              ],

              // 附加信息
              const SizedBox(height: 16),
              if (detail.countries.isNotEmpty)
                _infoRow(context, '国家', detail.countries.join(' / ')),
              if (detail.languages.isNotEmpty)
                _infoRow(context, '语言', detail.languages.join(' / ')),
              if (detail.durations.isNotEmpty)
                _infoRow(context, '时长', detail.durations.join(' / ')),
              if (detail.pubdate.isNotEmpty)
                _infoRow(context, '上映', detail.pubdate.join(' / ')),
              if (detail.aka.isNotEmpty)
                _infoRow(context, '别名', detail.aka.join(' / ')),
              if (detail.isTv) ...[
                _infoRow(context, '集数', '${detail.episodesCount}'),
                if (detail.episodesInfo.isNotEmpty)
                  _infoRow(context, '进度', detail.episodesInfo),
              ],

              // 导演 / 演员
              if (detail.directors.isNotEmpty) ...[
                const SizedBox(height: 12),
                _personRow(context, '导演', detail.directors),
              ],
              if (detail.actors.isNotEmpty) ...[
                const SizedBox(height: 4),
                _personRow(context, '主演', detail.actors.take(8).toList()),
              ],

              // 播放源
              if (detail.vendors.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '播放源',
                  style: context.theme.typography.sm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: detail.vendors
                      .map(
                        (v) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: context.theme.colors.muted,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: context.theme.colors.border.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (v.icon.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: CachedNetworkImage(
                                    imageUrl: v.icon,
                                    width: 18,
                                    height: 18,
                                    errorWidget: (_, __, ___) =>
                                        const SizedBox.shrink(),
                                  ),
                                ),
                              const SizedBox(width: 6),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    v.title,
                                    style: context.theme.typography.xs.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (v.paymentDesc.isNotEmpty)
                                    Text(
                                      v.paymentDesc,
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: context
                                            .theme
                                            .colors
                                            .mutedForeground,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],

              // 预告片
              if (detail.trailers.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '预告片',
                  style: context.theme.typography.sm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...detail.trailers.map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (t.coverUrl.isNotEmpty)
                            CachedNetworkImage(
                              imageUrl: t.coverUrl,
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                              httpHeaders: const {
                                'Referer': 'https://movie.douban.com/',
                                'User-Agent':
                                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                              },
                              errorWidget: (_, __, ___) => Container(
                                height: 180,
                                color: context.theme.colors.muted,
                              ),
                            ),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              FIcons.play,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${t.title} ${t.runtime}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              // 统计
              if (detail.commentCount > 0 || detail.reviewCount > 0) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (detail.commentCount > 0)
                      _statChip(context, '${detail.commentCount} 短评'),
                    if (detail.reviewCount > 0) ...[
                      const SizedBox(width: 8),
                      _statChip(context, '${detail.reviewCount} 影评'),
                    ],
                    if (detail.forumTopicCount > 0) ...[
                      const SizedBox(width: 8),
                      _statChip(context, '${detail.forumTopicCount} 讨论'),
                    ],
                  ],
                ),
              ],

              const SizedBox(height: 16),
            ],
          ),
        ),

        // ── 固定底部按钮 ──
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: FButton(
                onPress: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UnifiedSearchPage(
                        initialQuery: searchQuery,
                        initialMode: SearchMode.resource,
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FIcons.search, size: 16),
                    const SizedBox(width: 6),
                    const Text('搜索资源'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── 顶部背景海报 ──

  Widget _buildBackdrop(BuildContext context, String url) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: CachedNetworkImage(
        imageUrl: url,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
        httpHeaders: const {
          'Referer': 'https://movie.douban.com/',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
        placeholder: (_, __) => Container(
          height: 180,
          color: context.theme.colors.muted,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          height: 180,
          color: context.theme.colors.muted,
          child: Center(
            child: Icon(
              FIcons.film,
              size: 40,
              color: context.theme.colors.mutedForeground.withValues(
                alpha: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPoster(BuildContext context, String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: url,
        width: 110,
        height: 165,
        fit: BoxFit.cover,
        httpHeaders: const {
          'Referer': 'https://movie.douban.com/',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
        placeholder: (_, __) => Container(
          width: 110,
          height: 165,
          color: context.theme.colors.muted,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          width: 110,
          height: 165,
          decoration: BoxDecoration(
            color: context.theme.colors.muted,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            FIcons.film,
            size: 32,
            color: context.theme.colors.mutedForeground.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(
              label,
              style: context.theme.typography.xs.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
          ),
          Expanded(child: Text(value, style: context.theme.typography.xs)),
        ],
      ),
    );
  }

  Widget _personRow(BuildContext context, String label, List<Person> persons) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 48,
          child: Text(
            label,
            style: context.theme.typography.xs.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
        ),
        Expanded(
          child: Text(
            persons.map((p) => p.name).join(' / '),
            style: context.theme.typography.xs,
          ),
        ),
      ],
    );
  }

  Widget _statChip(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: context.theme.colors.muted,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: context.theme.typography.xs.copyWith(
          color: context.theme.colors.mutedForeground,
        ),
      ),
    );
  }
}
