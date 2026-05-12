import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

class AppDropdownMenu extends StatelessWidget {
  final List<shadcn.MenuItem> children;
  final double? surfaceOpacity;
  final double? surfaceBlur;
  final Axis direction;
  final Object? regionGroupId;

  const AppDropdownMenu({
    super.key,
    required this.children,
    this.surfaceOpacity,
    this.surfaceBlur,
    this.direction = Axis.vertical,
    this.regionGroupId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final densityGap = theme.density.baseGap * theme.scaling;
    final densityContentPadding =
        theme.density.baseContentPadding * theme.scaling;
    final isSheetOverlay = shadcn.SheetOverlayHandler.isSheetOverlay(context);

    return _AppPopoverMenuLayer(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 192),
        child: shadcn.MenuGroup(
          autofocus: false,
          regionGroupId:
              regionGroupId ??
              shadcn.Data.maybeOf<shadcn.DropdownMenuData>(context)?.key,
          subMenuOffset: Offset(densityGap, -densityGap * 0.5),
          itemPadding: isSheetOverlay
              ? EdgeInsets.symmetric(horizontal: densityContentPadding * 0.5)
              : EdgeInsets.zero,
          onDismissed: () => shadcn.closeOverlay(context),
          direction: direction,
          builder: (context, children) => shadcn.MenuPopup(
            surfaceOpacity: surfaceOpacity,
            surfaceBlur: surfaceBlur,
            children: children,
          ),
          children: children,
        ),
      ),
    );
  }
}

class _AppPopoverMenuLayer extends StatelessWidget {
  final Widget child;

  const _AppPopoverMenuLayer({required this.child});

  @override
  Widget build(BuildContext context) {
    // 交给 shadcn 默认 overlay 行为处理（移动端可自适应为 sheet）
    return child;
  }
}

class AppContextMenu extends StatelessWidget {
  final Widget child;
  final List<shadcn.MenuItem> items;
  final HitTestBehavior behavior;
  final Axis direction;
  final bool enabled;
  final bool openOnTap;

  const AppContextMenu({
    super.key,
    required this.child,
    required this.items,
    this.behavior = HitTestBehavior.translucent,
    this.direction = Axis.vertical,
    this.enabled = true,
    this.openOnTap = false,
  });

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final enableLongPress = platform == TargetPlatform.iOS ||
        platform == TargetPlatform.android ||
        platform == TargetPlatform.fuchsia;
    Offset? tapPosition;

    return GestureDetector(
      behavior: behavior,
      onTapDown: openOnTap && enabled
          ? (details) => tapPosition = details.globalPosition
          : null,
      onTap: openOnTap && enabled
          ? () {
              appShowContextMenu(
                context: context,
                position: tapPosition ?? Offset.zero,
                items: items,
                direction: direction,
              );
            }
          : null,
      onSecondaryTapDown: !enabled
          ? null
          : (details) {
              appShowContextMenu(
                context: context,
                position: details.globalPosition,
                items: items,
                direction: direction,
              );
            },
      onLongPressStart: enableLongPress && enabled
          ? (details) {
              appShowContextMenu(
                context: context,
                position: details.globalPosition,
                items: items,
                direction: direction,
              );
            }
          : null,
      child: child,
    );
  }
}

Future<void> appShowContextMenu({
  required BuildContext context,
  required Offset position,
  required List<shadcn.MenuItem> items,
  Axis direction = Axis.vertical,
}) async {
  final theme = shadcn.Theme.of(context);
  final key = GlobalKey();
  await shadcn
      .showPopover<void>(
        context: context,
        position: position + const Offset(8, 0),
        alignment: Alignment.topLeft,
        anchorAlignment: Alignment.topRight,
        regionGroupId: key,
        modal: true,
        follow: false,
        consumeOutsideTaps: false,
        dismissBackdropFocus: false,
        overlayBarrier: shadcn.OverlayBarrier(
          borderRadius: BorderRadius.circular(theme.radiusMd),
          barrierColor: const Color(0xB2000000),
        ),
        builder: (_) => AppDropdownMenu(
          children: items,
          direction: direction,
          regionGroupId: key,
        ),
      )
      .future;
}

class AppContextMenuPopup extends StatelessWidget {
  final BuildContext anchorContext;
  final Offset position;
  final List<shadcn.MenuItem> children;
  final Axis direction;
  final Size? anchorSize;

  const AppContextMenuPopup({
    super.key,
    required this.anchorContext,
    required this.position,
    required this.children,
    this.direction = Axis.vertical,
    this.anchorSize,
  });

  @override
  Widget build(BuildContext context) {
    return shadcn.PopoverOverlayWidget(
      anchorContext: anchorContext,
      position: position,
      anchorSize: anchorSize,
      alignment: Alignment.topLeft,
      follow: false,
      builder: (_) => AppDropdownMenu(children: children, direction: direction),
      animation: const AlwaysStoppedAnimation<double>(1),
      anchorAlignment: Alignment.topRight,
    );
  }
}
