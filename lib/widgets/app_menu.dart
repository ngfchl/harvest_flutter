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
