import 'package:shadcn_flutter/shadcn_flutter.dart';

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
  PopoverConstraint? widthConstraint,
  Key? key,
  bool modal = false,
  bool follow = true,
  OverlayBarrier? overlayBarrier,
  Object? regionGroupId,
  required WidgetBuilder builder,
}) {
  return showOverlay<T>(
    context,
    PopoverConfiguration(
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

// ────────────── material 等价兼容层 ──────────────

/// material Dialog 的轻量替代:居中卡片容器。
class Dialog extends StatelessWidget {
  final Widget? child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry? insetPadding;

  const Dialog({
    super.key,
    this.child,
    this.backgroundColor,
    this.padding,
    this.shape,
    this.insetPadding,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        width: 480,
        padding: padding ?? const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: backgroundColor ?? cs.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.border),
        ),
        child: child,
      ),
    );
  }
}

/// material SelectionArea 的轻量替代(shadcn 无等价物,直接放行子组件)。
class SelectionArea extends StatelessWidget {
  final Widget child;

  const SelectionArea({super.key, required this.child});

  @override
  Widget build(BuildContext context) => child;
}

/// material ListTile 的轻量替代:leading/title/subtitle/trailing 行布局。
class ListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;
  final bool dense;

  const ListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.contentPadding,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final row = Row(
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 12)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) title!,
              if (subtitle != null) ...[const SizedBox(height: 2), subtitle!],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: row,
      ),
    );
  }
}

/// material Material+InkWell 的无水纹替代:直接渲染子组件。
class Material extends StatelessWidget {
  final Color? color;
  final Widget? child;

  const Material({super.key, this.color, this.child});

  @override
  Widget build(BuildContext context) => child ?? const SizedBox.shrink();
}

class InkWell extends StatelessWidget {
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? child;

  const InkWell({super.key, this.borderRadius, this.onTap, this.onLongPress, this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }
}

/// material Chip 的轻量替代:标签+删除按钮。
class Chip extends StatelessWidget {
  final Widget label;
  final Widget? deleteIcon;
  final VoidCallback? onDeleted;

  const Chip({super.key, required this.label, this.deleteIcon, this.onDeleted});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.muted,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DefaultTextStyle.merge(
            style: TextStyle(fontSize: 12, color: cs.mutedForeground),
            child: label,
          ),
          if (deleteIcon != null && onDeleted != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onDeleted,
              child: IconTheme(
                data: IconThemeData(size: 16, color: cs.mutedForeground),
                child: deleteIcon!,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// material FilterChip 的轻量替代:可选中标签。
/// material FilterChip 的轻量替代。
class FilterChip extends StatelessWidget {
  final Widget label;
  final bool selected;
  final bool showCheckmark;
  final ValueChanged<bool>? onSelected;
  final Color? selectedColor;
  final BorderSide? side;
  final TextStyle? labelStyle;
  final EdgeInsetsGeometry? padding;

  const FilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.showCheckmark = true,
    this.selectedColor,
    this.side,
    this.labelStyle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final active = selected;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onSelected == null ? null : () => onSelected!(!selected),
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? (selectedColor ?? cs.primary.withValues(alpha: 0.15)) : const Color(0x00000000),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: side?.color ?? cs.border,
            width: side?.width ?? 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showCheckmark && active) ...[
              Icon(LucideIcons.check, size: 13, color: labelStyle?.color ?? cs.primary),
              const SizedBox(width: 4),
            ],
            DefaultTextStyle.merge(
              style: labelStyle ?? const TextStyle(fontSize: 12),
              child: label,
            ),
          ],
        ),
      ),
    );
  }
}
