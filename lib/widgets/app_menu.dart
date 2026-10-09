import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Simple menu widget for use in overlays/dropdowns.
Widget appMenu({required List<MenuItem> children, Axis direction = Axis.vertical}) {
  return ConstrainedBox(
    constraints: const BoxConstraints(minWidth: 192),
    child: MenuGroup(
      autofocus: false,
      direction: direction,
      builder: (_, children) => MenuPopup(children: children),
      children: children,
    ),
  );
}
