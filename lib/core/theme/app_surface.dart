import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import 'app_background_image.dart';
import 'theme_provider.dart';

double appSurfaceOpacity(BuildContext context) =>
    (shadcn.Theme.of(context).surfaceOpacity ?? 1.0).clamp(0.0, 1.0).toDouble();

Color appSurfaceColor(BuildContext context, Color color) =>
    color.withValues(alpha: appSurfaceOpacity(context));

double appSurfaceBlur(BuildContext context) =>
    (shadcn.Theme.of(context).surfaceBlur ?? 0.0).clamp(0.0, 40.0).toDouble();

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
    final blur = appSurfaceBlur(context);
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

    if (clip || blur > 0) {
      content = ClipRRect(
        borderRadius: radius.resolve(Directionality.of(context)),
        child: blur > 0
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: content,
              )
            : content,
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

class AppBackground extends ConsumerWidget {
  final Widget child;
  final double? overlayOpacity;

  const AppBackground({
    super.key,
    required this.child,
    this.overlayOpacity,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeNotifierProvider);
    final cs = shadcn.Theme.of(context).colorScheme;
    Widget background = ColoredBox(color: cs.background);
    if (themeState.useBackground) {
      final effectiveOverlayOpacity =
          overlayOpacity ?? (1.0 - themeState.surfaceOpacity).clamp(0.0, 1.0).toDouble();
      background = Stack(
        fit: StackFit.expand,
        children: [
          background,
          appThemeBackgroundImage(themeState),
          ColoredBox(color: cs.background.withValues(alpha: effectiveOverlayOpacity)),
        ],
      );
    }
    return Stack(fit: StackFit.expand, children: [background, child]);
  }
}
