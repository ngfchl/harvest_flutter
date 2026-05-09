import 'dart:math';

import 'package:flutter/material.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../dashboard_page.dart';
import '../model/dashboard_data.dart';

class TreemapSection extends StatefulWidget {
  final List<SiteStatusData> data;
  final bool privacy;
  final double height;
  final List<Color> colors; // ← 新增
  final int displayCount; // ← 新增

  const TreemapSection({
    super.key,
    required this.data,
    required this.privacy,
    this.height = 260,
    this.displayCount = 25, // ← 默认 15
    required this.colors, // ← 必传
  });

  @override
  State<TreemapSection> createState() => _TreemapSectionState();
}

class _TreemapSectionState extends State<TreemapSection> {
  static const _step = 15;
  late int _displayCount;

  String? _tooltipName;
  String? _tooltipUpload;
  String? _tooltipDownload;
  String? _tooltipDlRatio;

  String _mask(String name, bool privacy) {
    if (!privacy) return name;
    if (name.length <= 1) return '*';
    if (name.length == 2) return '${name[0]}*';
    return '${name[0]}*${name[name.length - 1]}';
  }

  @override
  void initState() {
    super.initState();
    _displayCount = widget.displayCount;
  }

  void _showSiteDetail(SiteStatusData item) {
    final ul = item.value.uploaded;
    final dl = item.value.downloaded;
    setState(() {
      _tooltipName = _mask(item.name, widget.privacy);
      _tooltipUpload = formatBytes(ul);
      _tooltipDownload = dl > 0 ? formatBytes(dl) : null;
      _tooltipDlRatio = (dl > 0 && dl > ul)
          ? '(${(dl / ul * 100).toStringAsFixed(0)}%)'
          : null;
    });
  }

  Widget _buildTooltipContent() {
    final theme = shadcn.Theme.of(context);
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Text(
            _tooltipName ?? '',
            style: theme.typography.small.copyWith(fontWeight: FontWeight.w700),
          ),
          // const SizedBox(height: 6),
          Row(
            spacing: 8,
            children: [
              Row(
                children: [
                  Icon(
                    shadcn.LucideIcons.arrowUp,
                    size: 10,
                    color: const Color(0xFF10B981),
                  ),
                  const SizedBox(width: 4),
                  // Text('上传', style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
                  // const SizedBox(width: 8),
                  Text(
                    _tooltipUpload ?? '',
                    style: theme.typography.xSmall.copyWith(
                      color: const Color(0xFF10B981),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (_tooltipDownload != null) ...[
                // const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      shadcn.LucideIcons.arrowDown,
                      size: 10,
                      color: const Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 4),
                    // Text('下载', style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
                    // const SizedBox(width: 8),
                    Text(
                      _tooltipDownload!,
                      style: theme.typography.xSmall.copyWith(
                        color: const Color(0xFFEF4444),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_tooltipDlRatio != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        _tooltipDlRatio!,
                        style: theme.typography.xSmall.copyWith(
                          color: const Color(0xFFEF4444),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ],
    );
  }

  Widget _buildTooltipPanel() {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    return shadcn.ModalContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SizedBox(
        width: 300,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(child: _buildTooltipContent()),
            const SizedBox(width: 8),
            shadcn.IconButton.ghost(
              density: shadcn.ButtonDensity.compact,
              icon: Icon(shadcn.LucideIcons.x, size: 15, color: cs.mutedForeground),
              onPressed: () => shadcn.closeOverlay(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showTreemapTooltip(BuildContext anchorContext) {
    shadcn.showPopover<void>(
      context: anchorContext,
      handler: const shadcn.PopoverOverlayHandler(),
      alignment: Alignment.topCenter,
      anchorAlignment: Alignment.bottomCenter,
      offset: const Offset(0, 8),
      consumeOutsideTaps: false,
      builder: (_) => _buildTooltipPanel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayItems = widget.data.take(_displayCount).toList();
    final hasMore = _displayCount < widget.data.length;
    final canReduce = _displayCount > _step;
    final colors = widget.colors;

    final items = <_TreemapItem>[];

    for (int i = 0; i < displayItems.length; i++) {
      final item = displayItems[i];
      items.add(
        _TreemapItem(
          name: _mask(item.name, widget.privacy),
          uploaded: item.value.uploaded.toDouble(),
          downloaded: item.value.downloaded.toDouble(),
          color: colors[i % colors.length],
        ),
      );
    }

    if (canReduce) {
      items.add(
        _TreemapItem(
          name: '收起',
          uploaded: widget.data
              .skip(_displayCount - _step)
              .take(_step)
              .fold<double>(0, (sum, e) => sum + e.value.uploaded.toDouble()),
          downloaded: 0,
          color: shadcn.Theme.of(
            context,
          ).colorScheme.mutedForeground.withValues(alpha: 0.3),
          isReduce: true,
        ),
      );
    }

    if (hasMore) {
      items.add(
        _TreemapItem(
          name: '更多',
          uploaded: widget.data
              .skip(_displayCount)
              .fold<double>(0, (sum, e) => sum + e.value.uploaded.toDouble()),
          downloaded: 0,
          color: shadcn.Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.3),
          isLast: true,
          remainingCount: widget.data.length - _displayCount,
        ),
      );
    }

    return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: widget.height,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final rects = _squarify(
                  items.map((e) => e.uploaded).toList(),
                  Rect.fromLTWH(
                    0,
                    0,
                    constraints.maxWidth,
                    constraints.maxHeight,
                  ),
                );

                return Stack(
                  children: List.generate(items.length, (i) {
                    final r = rects[i];
                    final item = items[i];
                    final dlColor = complementColor(item.color);

                    return Positioned(
                      left: r.left,
                      top: r.top,
                      width: r.width,
                      height: r.height,
                      child: Builder(
                        builder: (tileContext) => GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (item.isReduce) {
                              setState(
                                () => _displayCount = (_displayCount - _step)
                                    .clamp(_step, widget.data.length),
                              );
                              return;
                            }
                            if (item.isLast) {
                              setState(
                                () => _displayCount = (_displayCount + _step)
                                    .clamp(0, widget.data.length),
                              );
                              return;
                            }
                            final siteIndex = widget.data.indexWhere(
                              (e) => _mask(e.name, widget.privacy) == item.name,
                            );
                            if (siteIndex >= 0) {
                              _showSiteDetail(widget.data[siteIndex]);
                              _showTreemapTooltip(tileContext);
                            }
                          },
                        child: Container(
                          margin: const EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            color: item.color,
                            borderRadius: shadcn.Theme.of(
                              context,
                            ).borderRadiusSm,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.22),
                              width: 0.6,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: shadcn.Theme.of(
                              context,
                            ).borderRadiusSm,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withValues(alpha: 0.12),
                                          Colors.black.withValues(alpha: 0.10),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                  ),
                                ),
                                if (!item.isLast &&
                                    !item.isReduce &&
                                    item.downloaded > 0 &&
                                    item.uploaded > 0)
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    height:
                                        r.height *
                                        (item.downloaded / item.uploaded).clamp(
                                          0.0,
                                          1.0,
                                        ),
                                    child: Container(
                                      color: dlColor.withValues(alpha: 0.55),
                                    ),
                                  ),
                                if (item.isReduce)
                                  Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.remove_rounded,
                                          color: Colors.white,
                                          size: min(r.width, r.height) * 0.3,
                                        ),
                                        if (r.height > 40 && r.width > 40)
                                          const Text(
                                            '收起',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                      ],
                                    ),
                                  )
                                else if (item.isLast)
                                  Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_rounded,
                                          color: Colors.white,
                                          size: min(r.width, r.height) * 0.3,
                                        ),
                                        if (r.height > 40 && r.width > 40)
                                          Text(
                                            '+${item.remainingCount}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                      ],
                                    ),
                                  )
                                else if (r.width > 50 && r.height > 35)
                                  ClipRect(
                                    child: Padding(
                                      padding: const EdgeInsets.all(3),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.center,
                                        child: SizedBox(
                                          width: max(r.width - 6, 1),
                                          height: max(r.height - 6, 1),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                item.name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.black38,
                                                      blurRadius: 4,
                                                      offset: Offset(0, 1),
                                                    ),
                                                  ],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (r.height > 45) ...[
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 4,
                                                      height: 4,
                                                      decoration: BoxDecoration(
                                                        color: item.color,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 1),
                                                    Flexible(
                                                      child: Text(
                                                        formatBytes(
                                                          item.uploaded.toInt(),
                                                        ),
                                                        style: const TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 9,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                if (item.downloaded > 0)
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        width: 4,
                                                        height: 4,
                                                        decoration:
                                                            BoxDecoration(
                                                              color: dlColor,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                      ),
                                                      const SizedBox(width: 1),
                                                      Flexible(
                                                        child: Text(
                                                          formatBytes(
                                                                item.downloaded
                                                                    .toInt(),
                                                              ) +
                                                              (item.downloaded >
                                                                      item.uploaded
                                                                  ? ' (${(item.downloaded / item.uploaded * 100).toStringAsFixed(0)}%)'
                                                                  : ''),
                                                          style: TextStyle(
                                                            color:
                                                                item.downloaded >
                                                                    item.uploaded
                                                                ? dlColor
                                                                : Colors
                                                                      .white70,
                                                            fontSize: 9,
                                                            fontWeight:
                                                                item.downloaded >
                                                                    item.uploaded
                                                                ? FontWeight
                                                                      .w700
                                                                : FontWeight
                                                                      .w400,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
    );
  }

  List<Rect> _squarify(List<double> values, Rect rect) {
    if (values.isEmpty) return [];
    if (values.length == 1) return [rect];
    final total = values.fold<double>(0, (s, v) => s + v);
    final area = rect.width * rect.height;
    final areas = values.map((v) => v / total * area).toList();
    return _layout(areas, rect);
  }

  List<Rect> _layout(List<double> areas, Rect rect) {
    if (areas.isEmpty) return [];
    if (areas.length == 1) return [rect];
    final w = rect.width;
    final h = rect.height;
    if (w <= 0 || h <= 0) return List.filled(areas.length, rect);
    final shorter = min(w, h);
    var row = [areas[0]];
    var i = 1;
    while (i < areas.length) {
      final candidate = [...row, areas[i]];
      if (_worst(candidate, shorter) <= _worst(row, shorter)) {
        row = candidate;
        i++;
      } else {
        break;
      }
    }
    final rowSum = row.fold<double>(0, (s, v) => s + v);
    final rowRects = <Rect>[];
    double offset = 0;
    for (final a in row) {
      final fraction = a / rowSum;
      if (w >= h) {
        final cellH = h * fraction;
        rowRects.add(
          Rect.fromLTWH(rect.left, rect.top + offset, rowSum / h, cellH),
        );
        offset += cellH;
      } else {
        final cellW = w * fraction;
        rowRects.add(
          Rect.fromLTWH(rect.left + offset, rect.top, cellW, rowSum / w),
        );
        offset += cellW;
      }
    }
    Rect remaining;
    if (w >= h) {
      final rowW = rowSum / h;
      remaining = Rect.fromLTWH(
        rect.left + rowW,
        rect.top,
        max(w - rowW, 0),
        h,
      );
    } else {
      final rowH = rowSum / w;
      remaining = Rect.fromLTWH(
        rect.left,
        rect.top + rowH,
        w,
        max(h - rowH, 0),
      );
    }
    return [...rowRects, ..._layout(areas.sublist(i), remaining)];
  }

  double _worst(List<double> row, double shorter) {
    if (shorter <= 0) return double.infinity;
    final sum = row.fold<double>(0, (s, v) => s + v);
    if (sum <= 0) return double.infinity;
    final rowWidth = sum / shorter;
    if (rowWidth <= 0) return double.infinity;
    double worst = 0;
    for (final a in row) {
      final cellLen = a / rowWidth;
      if (cellLen <= 0) continue;
      final ratio = rowWidth > cellLen
          ? rowWidth / cellLen
          : cellLen / rowWidth;
      if (ratio > worst) worst = ratio;
    }
    return worst;
  }
}

class _TreemapItem {
  final String name;
  final double uploaded;
  final double downloaded;
  final Color color;
  final bool isLast;
  final bool isReduce;
  final int remainingCount;

  const _TreemapItem({
    required this.name,
    required this.uploaded,
    required this.downloaded,
    required this.color,
    this.isLast = false,
    this.isReduce = false,
    this.remainingCount = 0,
  });
}
