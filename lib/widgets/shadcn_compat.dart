import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

/// Compatibility shim for removed shadcn classes.

class OverlayManagerLayer extends StatelessWidget {
  final Widget child;
  final Object? popoverHandler;
  final Object? tooltipHandler;
  final Object? menuHandler;
  final Object? handler;

  const OverlayManagerLayer({
    super.key,
    this.popoverHandler,
    this.tooltipHandler,
    this.menuHandler,
    this.handler,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => child;
}

class PopoverOverlayHandler {
  const PopoverOverlayHandler();
}

class FixedTooltipOverlayHandler {
  const FixedTooltipOverlayHandler();
}

/// showPopover -> showOverlay + PopoverConfiguration
Future<T?> showPopover<T>({
  required BuildContext context,
  Alignment alignment = Alignment.bottomCenter,
  Alignment? anchorAlignment,
  Offset? offset,
  bool consumeOutsideTaps = true,
  Object? handler,
  shadcn.PopoverConstraint? widthConstraint,
  shadcn.Key? key,
  bool modal = false,
  bool follow = true,
  shadcn.OverlayBarrier? overlayBarrier,
  Object? regionGroupId,
  required WidgetBuilder builder,
}) {
  return shadcn.showOverlay<T>(
    context,
    shadcn.PopoverConfiguration(
      alignment: alignment,
      anchorAlignment: anchorAlignment,
      offset: offset,
      consumeOutsideTaps: consumeOutsideTaps,
      rootOverlay: true,
      key: key,
      modal: modal,
      follow: follow,
      overlayBarrier: overlayBarrier,
      regionGroupId: regionGroupId,
    ),
    builder: builder,
  ).future;
}
