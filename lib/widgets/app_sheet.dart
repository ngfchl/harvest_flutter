import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

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
  final cs = shadcn.Theme.of(context).colorScheme;
  final maxHeight = media == null
      ? null
      : isScrollControlled
      ? media.size.height * 0.9
      : media.size.height * 0.72;

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    showDragHandle: showDragHandle,
    backgroundColor: Colors.transparent,
    shape: shape,
    constraints: constraints ?? (maxHeight == null ? null : BoxConstraints(maxHeight: maxHeight)),
    builder: (sheetContext) {
      final sheetMedia = MediaQuery.of(sheetContext);
      final child = builder(sheetContext);
      return LayoutBuilder(
        builder: (context, constraints) {
          final maxSheetHeight = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : sheetMedia.size.height * (isScrollControlled ? 0.9 : 0.72);
          return SafeArea(
            top: false,
            bottom: true,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxSheetHeight),
                child: Container(
                  decoration: BoxDecoration(
                    color: backgroundColor ?? cs.background,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    border: Border(
                      top: BorderSide(color: cs.border.withValues(alpha: 0.78), width: 0.8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showDefaultHeader)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 4, 8, 2),
                          child: Row(
                            children: [
                              shadcn.IconButton.ghost(
                                onPressed: () => closeAppSheet(sheetContext),
                                icon: const Icon(shadcn.LucideIcons.arrowLeft, size: 16),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  title ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: shadcn.Theme.of(sheetContext).typography.large.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (showDragHandle ?? true)
                        Padding(
                          padding: const EdgeInsets.only(top: 5, bottom: 4),
                          child: Container(
                            width: 34,
                            height: 4,
                            decoration: BoxDecoration(
                              color: cs.mutedForeground.withValues(alpha: 0.32),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      Flexible(
                        fit: FlexFit.loose,
                        child: child,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> closeAppSheet<T>(BuildContext context, [T? result]) {
  final overlay = shadcn.Data.maybeFind<shadcn.OverlayHandlerStateMixin>(context);
  if (overlay != null) {
    return overlay.closeWithResult<T>(result);
  }
  return Navigator.of(context).maybePop<T>(result);
}
