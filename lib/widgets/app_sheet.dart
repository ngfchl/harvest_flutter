import 'package:shadcn_flutter/shadcn_flutter.dart';

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

  return showOverlay<T>(
    context,
    SheetConfiguration(
      position: OverlayPosition.bottom,
      barrierDismissible: isDismissible,
      draggable: enableDrag,
      barrierColor: Colors.black.withValues(alpha: 0.26),
      constraints: constraints ?? (maxHeight == null ? null : BoxConstraints(maxHeight: maxHeight)),
    ),
    builder: (sheetContext) {
      final sheetMedia = MediaQuery.maybeOf(sheetContext);
      final child = builder(sheetContext);
      return LayoutBuilder(
        builder: (context, constraints) {
          final maxSheetHeight = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : (sheetMedia?.size.height ?? MediaQuery.sizeOf(context).height) *
                  (isScrollControlled ? 0.9 : 0.72);
          return SafeArea(
            top: false,
            bottom: true,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxSheetHeight),
                child: Container(
                  decoration: BoxDecoration(
                    color: effectiveSheetColor,
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
                          if (effectiveShowDragHandle) _AppSheetDragHandle(cs: cs),
                          if (showDefaultHeader)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 4, 8, 2),
                              child: Row(
                                children: [
                                  IconButton.ghost(
                                    onPressed: () => closeAppSheet(sheetContext),
                                    icon: const Icon(LucideIcons.arrowLeft, size: 16),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      title ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(
                                        sheetContext,
                                      ).typography.large.copyWith(color: cs.foreground, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Flexible(fit: FlexFit.loose, child: child),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  ).future;
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
  await closeOverlay<T>(context, result);
}
