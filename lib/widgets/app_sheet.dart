import 'package:shadcn_flutter/shadcn_flutter.dart';

/// 基于 Navigator 路由的自绘模态底部弹层。
///
/// 不使用 shadcn 的 SheetWrapper——其会自绘一层表面与拖动条,与本项目
/// 自绘表面叠层(出现"空白上层 + 内容下层"的双 sheet)。这里由本文件
/// 提供唯一的表面、拖动条与阻隔层,样式与全局设计一致。
Future<T?> showAppSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  String? title,
  bool showDefaultHeader = false,
  bool isScrollControlled = false,
  bool isDismissible = true,
  bool enableDrag = true,
  bool? showDragHandle,
  Color? backgroundColor,
  ShapeBorder? shape,
  BoxConstraints? constraints,
}) {
  final media = MediaQuery.maybeOf(context);
  final cs = Theme.of(context).colorScheme;
  final effectiveShowDragHandle = showDragHandle ?? true;
  final effectiveSheetColor = (backgroundColor == null || (backgroundColor.a * 255.0).round() == 0)
      ? cs.background
      : backgroundColor;
  final maxHeight = media == null
      ? null
      : isScrollControlled
      ? media.size.height * 0.9
      : media.size.height * 0.72;

  return Navigator.of(context, rootNavigator: true).push<T>(
    PageRouteBuilder(
      opaque: false,
      barrierDismissible: isDismissible,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, routeAnimation, _) => _AppSheetPage<T>(
        routeAnimation: routeAnimation,
        builder: builder,
        title: title,
        showDefaultHeader: showDefaultHeader,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        showDragHandle: effectiveShowDragHandle,
        sheetColor: effectiveSheetColor,
        panelConstraints: constraints ?? (maxHeight == null ? null : BoxConstraints(maxHeight: maxHeight)),
        barrierColor: Colors.black.withValues(alpha: 0.26),
      ),
      // 页面内部自行处理进场/退场动画,路由层不再叠加变换
      transitionsBuilder: (_, __, ___, child) => child,
    ),
  );
}

/// 单个 app sheet 的完整页面:阻隔层 + 底部面板。
class _AppSheetPage<T> extends StatefulWidget {
  final Animation<double> routeAnimation;
  final WidgetBuilder builder;
  final String? title;
  final bool showDefaultHeader;
  final bool isDismissible;
  final bool enableDrag;
  final bool showDragHandle;
  final Color sheetColor;
  final BoxConstraints? panelConstraints;
  final Color barrierColor;

  const _AppSheetPage({
    required this.routeAnimation,
    required this.builder,
    required this.showDefaultHeader,
    required this.isDismissible,
    required this.enableDrag,
    required this.showDragHandle,
    required this.sheetColor,
    required this.panelConstraints,
    required this.barrierColor,
    this.title,
  });

  @override
  State<_AppSheetPage<T>> createState() => _AppSheetPageState<T>();
}

class _AppSheetPageState<T> extends State<_AppSheetPage<T>> {
  /// 下滑关闭的拖拽进度(0~1),松手未过阈值时回弹到 0。
  double _dragFraction = 0;

  void _dismiss() => Navigator.of(context).pop<T>();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final anim = CurvedAnimation(
      parent: widget.routeAnimation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    final panel = Container(
      decoration: BoxDecoration(
        color: widget.sheetColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(top: BorderSide(color: cs.border.withValues(alpha: 0.78), width: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: cs.foreground),
        child: IconTheme.merge(
          data: IconThemeData(color: cs.foreground),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showDragHandle) _AppSheetDragHandle(cs: cs),
              if (widget.showDefaultHeader)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 2),
                  child: Row(
                    children: [
                      IconButton.ghost(
                        onPressed: _dismiss,
                        icon: const Icon(LucideIcons.arrowLeft, size: 16),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.title ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).typography.large.copyWith(color: cs.foreground, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              Flexible(fit: FlexFit.loose, child: widget.builder(context)),
            ],
          ),
        ),
      ),
    );

    final draggablePanel = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: widget.enableDrag
          ? (details) {
              final delta = details.primaryDelta ?? 0;
              setState(() => _dragFraction = (_dragFraction + delta / 400).clamp(0.0, 1.0));
            }
          : null,
      onVerticalDragEnd: widget.enableDrag
          ? (details) {
              final velocity = details.velocity.pixelsPerSecond.dy;
              if (velocity > 700 || _dragFraction > 0.35) {
                _dismiss();
              } else {
                setState(() => _dragFraction = 0);
              }
            }
          : null,
      child: panel,
    );

    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) {
        final t = anim.value.clamp(0.0, 1.0);
        // 进场滑入量 + 用户下拖量,合成为面板的竖向位移(以面板高度为基准)
        final slide = ((1 - t) + _dragFraction).clamp(0.0, 2.0);
        return Stack(
          fit: StackFit.expand,
          children: [
            // 阻隔层:点击关闭,透明度随路由动画淡入淡出
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.isDismissible ? _dismiss : null,
              child: FadeTransition(
                opacity: anim,
                child: Container(color: widget.barrierColor),
              ),
            ),
            SafeArea(
              top: false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: widget.panelConstraints ?? const BoxConstraints(),
                  child: FractionalTranslation(
                    translation: Offset(0, slide),
                    child: draggablePanel,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AppSheetDragHandle extends StatelessWidget {
  final ColorScheme cs;

  const _AppSheetDragHandle({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: cs.foreground.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

Future<void> closeAppSheet<T>(BuildContext context, [T? result]) async {
  Navigator.of(context).pop<T>(result);
}
