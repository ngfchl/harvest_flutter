import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

/// Simple menu widget for use in overlays/dropdowns.
Widget appMenu({
  required List<shadcn.MenuItem> children,
  Axis direction = Axis.vertical,
}) {
  return ConstrainedBox(
    constraints: const BoxConstraints(minWidth: 192),
    child: shadcn.MenuGroup(
      autofocus: false,
      direction: direction,
      builder: (_, children) => shadcn.MenuPopup(children: children),
      children: children,
    ),
  );
}

/// Programmatic context menu at a specific position.
Future<void> appShowContextMenu({
  required BuildContext context,
  required Offset position,
  required List<shadcn.MenuItem> items,
  Axis direction = Axis.vertical,
}) {
  final overlay = Overlay.of(context);
  final completer = Completer<void>();
  late final OverlayEntry entry;
  var removed = false;

  void close() {
    if (removed) return;
    removed = true;
    entry.remove();
    if (!completer.isCompleted) completer.complete();
  }

  entry = OverlayEntry(
    builder: (_) => Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: close,
            onSecondaryTapDown: (_) => close(),
          ),
        ),
        Positioned(
          left: position.dx,
          top: position.dy,
          child: Material(
            color: Colors.transparent,
            child: shadcn.MenuGroup(
              autofocus: true,
              direction: direction,
              onDismissed: close,
              builder: (_, children) => shadcn.MenuPopup(children: children),
              children: items,
            ),
          ),
        ),
      ],
    ),
  );
  overlay.insert(entry);
  return completer.future;
}
