import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

Color appSurfaceColor(BuildContext context, Color color) => color;

Color appSurfaceBorderColor(BuildContext context, [double alpha = 0.62]) =>
    shadcn.Theme.of(context).colorScheme.border.withValues(alpha: alpha);

class AppSurfaceContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final bool clip;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;

  const AppSurfaceContainer({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.borderRadius,
    this.color,
    this.borderColor,
    this.borderWidth = 0.5,
    this.clip = true,
    this.width,
    this.height,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final radius = borderRadius ?? theme.borderRadiusMd;
    Widget content = DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? appSurfaceColor(context, cs.card),
        borderRadius: radius,
        border: Border.all(
          color: borderColor ?? appSurfaceBorderColor(context),
          width: borderWidth,
        ),
      ),
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );

    if (clip) {
      content = ClipRRect(
        borderRadius: radius.resolve(Directionality.of(context)),
        child: content,
      );
    }

    if (width != null || height != null) {
      content = SizedBox(width: width, height: height, child: content);
    }
    if (constraints != null) {
      content = ConstrainedBox(constraints: constraints!, child: content);
    }

    return margin == null ? content : Padding(padding: margin!, child: content);
  }
}

class AppSurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;

  const AppSurfaceCard({
    super.key,
    required this.child,
    this.margin,
    this.padding = const EdgeInsets.all(12),
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurfaceContainer(
      margin: margin,
      padding: padding,
      borderRadius: shadcn.Theme.of(context).borderRadiusMd,
      color: color,
      borderColor: borderColor,
      child: child,
    );
  }
}

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return ColoredBox(color: cs.background, child: child);
  }
}
