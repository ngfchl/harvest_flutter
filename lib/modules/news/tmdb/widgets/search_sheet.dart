import 'dart:async';
import 'package:harvest/widgets/shad_text_field.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:harvest/widgets/app_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' show TextExtension;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../model/media_item.dart';
import '../service/tmdb_service.dart';
import 'tmdb_detail_sheet.dart';

void openTmdbSearch(BuildContext context, WidgetRef ref) {
  if (context.isMobile) {
    showAppSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: shadcn.Theme.of(context).borderRadiusLg),
      builder: (_) => _SearchSheet(ref: ref),
    );
  } else {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: shadcn.Theme.of(context).borderRadiusLg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
          child: _SearchSheet(ref: ref),
        ),
      ),
    );
  }
}

class _SearchSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;

  const _SearchSheet({required this.ref});

  @override
  ConsumerState<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends ConsumerState<_SearchSheet> {
  final _ctrl = TextEditingController();
  Timer? _debounce;
  String _query = '';
  bool _loading = false;
  List<MediaItem> _results = [];

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(v));
  }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) {
      setState(() {
        _results = [];
        _query = '';
      });
      return;
    }
    setState(() {
      _loading = true;
      _query = q.trim();
    });
    try {
      final data = await TmdbService.search(q.trim());
      if (mounted) setState(() => _results = data);
    } catch (_) {
      if (mounted) setState(() => _results = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;
    final cs = shadcn.Theme.of(context).colorScheme;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    final content = Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (mobile) ...[const SizedBox(height: 12), buildHandle(context), const SizedBox(height: 12)],

            // 搜索输入框
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ShadTextField(
                controller: _ctrl,
                hintText: '搜索电影、剧集...',
                maxLines: 1,
                onChanged: _onChanged,
                onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                autofocus: true,
                features: [
                  shadcn.InputFeature.leading(Icon(shadcn.LucideIcons.search, size: 16, color: cs.mutedForeground)),
                  if (_query.isNotEmpty)
                    shadcn.InputFeature.trailing(
                      shadcn.IconButton.ghost(
                        size: shadcn.ButtonSize.small,
                        density: shadcn.ButtonDensity.iconDense,
                        onPressed: () {
                          _ctrl.clear();
                          setState(() {
                            _query = '';
                            _results = [];
                          });
                        },
                        icon: const Icon(shadcn.LucideIcons.x, size: 14),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 结果
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: shadcn.CircularProgressIndicator()),
              )
            else if (_query.isNotEmpty && _results.isEmpty)
              Padding(padding: const EdgeInsets.all(24), child: Text('没有找到「$_query」').small.muted)
            else if (_results.isNotEmpty)
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => const shadcn.Divider(),
                  itemBuilder: (_, i) => _buildResultTile(context, _results[i]),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(shadcn.LucideIcons.search, size: 40, color: cs.mutedForeground.withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                    const Text('输入关键词开始搜索').small.muted,
                  ],
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (mobile) return SafeArea(child: content);
    return Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: content);
  }

  Widget _buildResultTile(BuildContext context, MediaItem item) {
    final posterUrl = TmdbService.imageUrl(item.posterPath, size: 'w92');
    final cs = shadcn.Theme.of(context).colorScheme;

    return shadcn.Clickable(
      onPressed: () {
        closeAppSheet(context);
        openTmdbDetail(context, item);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: shadcn.Theme.of(context).borderRadiusSm,
              child: SizedBox(
                width: 46,
                height: 69,
                child: posterUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: posterUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: shadcn.CircularProgressIndicator(strokeWidth: 1.5),
                          ),
                        ),
                        errorWidget: (_, __, ___) => _ph(context),
                      )
                    : _ph(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title).small.semiBold,
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (item.releaseDate.isNotEmpty) Text(item.releaseDate).xSmall.muted,
                      if (item.voteAverage != null && item.voteAverage! > 0) ...[
                        const SizedBox(width: 8),
                        Icon(shadcn.LucideIcons.star, size: 12, color: cs.chart4),
                        const SizedBox(width: 2),
                        Text(item.voteAverage!.toStringAsFixed(1)).xSmall.muted,
                      ],
                      if (item.mediaType.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        item.mediaType == 'movie'
                            ? const shadcn.SecondaryBadge(child: Text('电影'))
                            : const shadcn.OutlineBadge(child: Text('剧集')),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ph(BuildContext ctx) => ColoredBox(
    color: shadcn.Theme.of(ctx).colorScheme.muted,
    child: Center(
      child: Icon(
        shadcn.LucideIcons.film,
        size: 20,
        color: shadcn.Theme.of(ctx).colorScheme.mutedForeground.withValues(alpha: 0.3),
      ),
    ),
  );
}
