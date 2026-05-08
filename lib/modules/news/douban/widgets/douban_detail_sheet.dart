import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' show TextExtension;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: shadcn.Theme.of(
        context,
      ).colorScheme.background.withValues(alpha: 0),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.75,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollCtrl) =>
            _DoubanDetailSheet(subjectId: subjectId),
      ),
    );
  } else {
    final theme = shadcn.Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: theme.borderRadiusLg),
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
    return match.group(1)!;
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
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;

    final Widget body;
    if (_loading) {
      body = const Center(child: shadcn.CircularProgressIndicator());
    } else if (_error != null || _detail == null) {
      body = Center(child: Text('加载失败: $_error').small.muted);
    } else {
      body = _buildContent(context, _detail!);
    }

    return shadcn.Card(
      filled: true,
      fillColor: cs.background,
      borderRadius: theme.borderRadiusLg,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              children: [
                shadcn.IconButton.ghost(
                  icon: const Icon(shadcn.LucideIcons.arrowLeft, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ).base.semiBold,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: shadcn.Divider(),
          ),
          Flexible(child: body),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, VideoDetail detail) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final hasRating = detail.rating.value > 0;
    final ratingText = hasRating ? detail.rating.value.toStringAsFixed(1) : '';
    final searchQuery = detail.title;

    return Column(
      children: [
        _buildBackdrop(context, detail.coverUrl),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPoster(context, detail.coverUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(detail.title).large.bold,
                        if (detail.originalTitle.isNotEmpty &&
                            detail.originalTitle != detail.title) ...[
                          const SizedBox(height: 2),
                          Text(detail.originalTitle).xSmall.muted,
                        ],
                        if (detail.year.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(detail.year).small.muted,
                        ],
                        if (detail.genres.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: detail.genres
                                .map(
                                  (g) => shadcn.SecondaryBadge(child: Text(g)),
                                )
                                .toList(),
                          ),
                        ],
                        const SizedBox(height: 8),
                        if (hasRating)
                          Row(
                            children: [
                              Icon(
                                shadcn.LucideIcons.star,
                                size: 16,
                                color: cs.chart4,
                              ),
                              const SizedBox(width: 4),
                              Text(ratingText).base.bold,
                              const SizedBox(width: 4),
                              Text('(${detail.rating.count})').xSmall.muted,
                            ],
                          )
                        else if (detail.nullRatingReason.isNotEmpty)
                          Text(detail.nullRatingReason).xSmall.muted.italic,
                        if (detail.realtimeHonorInfos.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: detail.realtimeHonorInfos
                                .map(
                                  (h) => shadcn.OutlineBadge(
                                    child: Text('${h.title} #${h.rank}'),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (detail.intro.isNotEmpty) ...[
                const SizedBox(height: 16),
                _sectionTitle('简介'),
                const SizedBox(height: 6),
                Text(detail.intro).small.muted,
              ],
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
              if (detail.directors.isNotEmpty) ...[
                const SizedBox(height: 12),
                _personRow(context, '导演', detail.directors),
              ],
              if (detail.actors.isNotEmpty) ...[
                const SizedBox(height: 4),
                _personRow(context, '主演', detail.actors.take(8).toList()),
              ],
              if (detail.vendors.isNotEmpty) ...[
                const SizedBox(height: 16),
                _sectionTitle('播放源'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: detail.vendors
                      .map((v) => _vendorCard(context, v))
                      .toList(),
                ),
              ],
              if (detail.trailers.isNotEmpty) ...[
                const SizedBox(height: 16),
                _sectionTitle('预告片'),
                const SizedBox(height: 8),
                ...detail.trailers.map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _trailerCard(context, t),
                  ),
                ),
              ],
              if (detail.commentCount > 0 || detail.reviewCount > 0) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (detail.commentCount > 0)
                      _statChip('${detail.commentCount} 短评'),
                    if (detail.reviewCount > 0)
                      _statChip('${detail.reviewCount} 影评'),
                    if (detail.forumTopicCount > 0)
                      _statChip('${detail.forumTopicCount} 讨论'),
                  ],
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: shadcn.Button.primary(
                alignment: Alignment.center,
                leading: const Icon(shadcn.LucideIcons.search, size: 16),
                onPressed: () {
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
                child: const Text('搜索资源'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text).small.semiBold;
  }

  Widget _vendorCard(BuildContext context, Vendor vendor) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    return shadcn.Card(
      filled: true,
      fillColor: cs.muted,
      borderColor: cs.border.withValues(alpha: 0.3),
      borderRadius: theme.borderRadiusMd,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (vendor.icon.isNotEmpty)
            ClipRRect(
              borderRadius: theme.borderRadiusSm,
              child: CachedNetworkImage(
                imageUrl: vendor.icon,
                width: 18,
                height: 18,
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          if (vendor.icon.isNotEmpty) const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(vendor.title).xSmall.semiBold,
              if (vendor.paymentDesc.isNotEmpty)
                Text(vendor.paymentDesc).xSmall.muted,
            ],
          ),
        ],
      ),
    );
  }

  Widget _trailerCard(BuildContext context, Trailer trailer) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    return ClipRRect(
      borderRadius: theme.borderRadiusMd,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (trailer.coverUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: trailer.coverUrl,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              httpHeaders: const {
                'Referer': 'https://movie.douban.com/',
                'User-Agent':
                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
              },
              placeholder: (_, __) => _loadingBox(height: 180),
              errorWidget: (_, __, ___) => _mutedBox(context, height: 180),
            )
          else
            _mutedBox(context, height: 180),
          shadcn.Card(
            filled: true,
            fillColor: cs.popover.withValues(alpha: 0.75),
            borderColor: cs.border.withValues(alpha: 0.2),
            borderRadius: theme.borderRadiusLg,
            padding: const EdgeInsets.all(12),
            child: Icon(
              shadcn.LucideIcons.play,
              size: 20,
              color: cs.popoverForeground,
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: shadcn.Card(
              filled: true,
              fillColor: cs.popover.withValues(alpha: 0.8),
              borderColor: cs.border.withValues(alpha: 0.2),
              borderRadius: theme.borderRadiusSm,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Text(
                '${trailer.title} ${trailer.runtime}',
              ).xSmall.primaryForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackdrop(BuildContext context, String url) {
    final theme = shadcn.Theme.of(context);
    return ClipRRect(
      borderRadius: theme.borderRadiusLg,
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
        placeholder: (_, __) => _loadingBox(height: 180),
        errorWidget: (_, __, ___) => _posterFallback(
          context,
          width: double.infinity,
          height: 180,
          iconSize: 40,
          iconAlpha: 0.2,
        ),
      ),
    );
  }

  Widget _buildPoster(BuildContext context, String url) {
    final theme = shadcn.Theme.of(context);
    return ClipRRect(
      borderRadius: theme.borderRadiusMd,
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
        placeholder: (_, __) => _loadingBox(width: 110, height: 165),
        errorWidget: (_, __, ___) => _posterFallback(
          context,
          width: 110,
          height: 165,
          iconSize: 32,
          iconAlpha: 0.3,
        ),
      ),
    );
  }

  Widget _loadingBox({double? width, required double height}) {
    return Builder(
      builder: (context) {
        final cs = shadcn.Theme.of(context).colorScheme;
        return ColoredBox(
          color: cs.muted,
          child: SizedBox(
            width: width,
            height: height,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: shadcn.CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _mutedBox(
    BuildContext context, {
    double? width,
    required double height,
  }) {
    return ColoredBox(
      color: shadcn.Theme.of(context).colorScheme.muted,
      child: SizedBox(width: width, height: height),
    );
  }

  Widget _posterFallback(
    BuildContext context, {
    double? width,
    required double height,
    required double iconSize,
    required double iconAlpha,
  }) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return ColoredBox(
      color: cs.muted,
      child: SizedBox(
        width: width,
        height: height,
        child: Icon(
          shadcn.LucideIcons.film,
          size: iconSize,
          color: cs.mutedForeground.withValues(alpha: iconAlpha),
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
          SizedBox(width: 48, child: Text(label).xSmall.muted),
          Expanded(child: Text(value).xSmall),
        ],
      ),
    );
  }

  Widget _personRow(BuildContext context, String label, List<Person> persons) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 48, child: Text(label).xSmall.muted),
        Expanded(child: Text(persons.map((p) => p.name).join(' / ')).xSmall),
      ],
    );
  }

  Widget _statChip(String text) {
    return shadcn.SecondaryBadge(child: Text(text));
  }
}
