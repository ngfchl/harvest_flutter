import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:harvest/core/utils/utils.dart';

import '../model/media_item.dart';
import '../service/tmdb_service.dart';
import 'tmdb_detail_sheet.dart';

void openTmdbSearch(BuildContext context, WidgetRef ref) {
  if (context.isMobile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _SearchSheet(ref: ref),
    );
  } else {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    final content = Padding(
      padding: EdgeInsets.only(bottom: bottom),  // ← 键盘高度
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mobile) ...[const SizedBox(height: 12), buildHandle(context), const SizedBox(height: 12)],

          // 搜索输入框
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FTextField(
              controller: _ctrl,
              hint: '搜索电影、剧集...',
              onChange: _onChanged,
              autofocus: true,
              prefixBuilder: (ctx, styles, child) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(FIcons.search, size: 16, color: ctx.theme.colors.mutedForeground),
              ),
              suffixBuilder: _query.isNotEmpty
                  ? (ctx, styles, child) => GestureDetector(
                onTap: () {
                  _ctrl.clear();
                  setState(() { _query = ''; _results = []; });
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(FIcons.x, size: 14, color: ctx.theme.colors.mutedForeground),
                ),
              )
                  : null,
            ),
          ),
          const SizedBox(height: 12),

          // 结果
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_query.isNotEmpty && _results.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                '没有找到「$_query」',
                style: context.theme.typography.sm.copyWith(color: context.theme.colors.mutedForeground),
              ),
            )
          else if (_results.isNotEmpty)
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => FDivider(
                    style: FDividerStyle(color: context.theme.colors.border, padding: EdgeInsets.zero, width: 0.5),
                  ),
                  itemBuilder: (_, i) => _buildResultTile(context, _results[i]),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FIcons.search, size: 40, color: context.theme.colors.mutedForeground.withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                    Text(
                      '输入关键词开始搜索',
                      style: context.theme.typography.sm.copyWith(color: context.theme.colors.mutedForeground),
                    ),
                  ],
                ),
              ),
          const SizedBox(height: 16),
        ],
      ),
    );

    if (mobile) return SafeArea(child: content);
    return Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: content);
  }

  Widget _buildResultTile(BuildContext context, MediaItem item) {
    final posterUrl = TmdbService.imageUrl(item.posterPath, size: 'w92');

    return FTile(
      onPress: () {
        Navigator.pop(context);
        openTmdbDetail(context, item);
      },
      prefix: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: 46,
          height: 69,
          child: posterUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: posterUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const Center(
                    child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 1.5)),
                  ),
                  errorWidget: (_, __, ___) => _ph(context),
                )
              : _ph(context),
        ),
      ),
      title: Text(item.title, style: context.theme.typography.sm.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Row(
        children: [
          if (item.releaseDate.isNotEmpty)
            Text(
              item.releaseDate,
              style: context.theme.typography.xs.copyWith(color: context.theme.colors.mutedForeground),
            ),
          if (item.voteAverage != null && item.voteAverage! > 0) ...[
            const SizedBox(width: 8),
            Icon(FIcons.star, size: 12, color: Colors.amber),
            const SizedBox(width: 2),
            Text(
              item.voteAverage!.toStringAsFixed(1),
              style: context.theme.typography.xs.copyWith(color: context.theme.colors.mutedForeground),
            ),
          ],
          if (item.mediaType.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              item.mediaType == 'movie' ? '电影' : '剧集',
              style: TextStyle(
                fontSize: 10,
                color: item.mediaType == 'movie' ? context.theme.colors.primary : context.theme.colors.destructive,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _ph(BuildContext ctx) => Container(
    color: ctx.theme.colors.muted,
    child: Center(child: Icon(FIcons.film, size: 20, color: ctx.theme.colors.mutedForeground.withValues(alpha: 0.3))),
  );
}
