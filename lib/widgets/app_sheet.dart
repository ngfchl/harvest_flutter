import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

Future<T?> showAppSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool isDismissible = true,
  bool enableDrag = true,
  bool? showDragHandle,
  Color? backgroundColor,
  ShapeBorder? shape,
  BoxConstraints? constraints,
}) {
  final media = MediaQuery.maybeOf(context);
  final maxHeight = media == null
      ? null
      : isScrollControlled
      ? media.size.height
      : media.size.height * 0.65;

  return shadcn.openSheet<T>(
    context: context,
    position: shadcn.OverlayPosition.bottom,
    barrierDismissible: isDismissible,
    draggable: enableDrag,
    constraints: constraints ?? (maxHeight == null ? null : BoxConstraints(maxHeight: maxHeight)),
    builder: (sheetContext) => builder(sheetContext),
  );
}

Future<void> closeAppSheet<T>(BuildContext context, [T? result]) {
  final overlay = shadcn.Data.maybeFind<shadcn.OverlayHandlerStateMixin>(context);
  if (overlay != null) {
    return overlay.closeWithResult<T>(result);
  }
  return Navigator.of(context).maybePop<T>(result);
}
