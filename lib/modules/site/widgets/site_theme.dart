import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;


shadcn.ThemeData siteTheme(BuildContext context) => shadcn.Theme.of(context);

shadcn.ColorScheme siteColors(BuildContext context) => siteTheme(context).colorScheme;

Color siteTone(
  Color color, {
  double hueShift = 0,
  double saturationScale = 1,
  double lightnessDelta = 0,
  double alpha = 1,
}) {
  final hsl = HSLColor.fromColor(color);
  return hsl
      .withHue((hsl.hue + hueShift) % 360)
      .withSaturation((hsl.saturation * saturationScale).clamp(0.14, 0.9))
      .withLightness((hsl.lightness + lightnessDelta).clamp(0.22, 0.78))
      .toColor()
      .withValues(alpha: alpha);
}

Color siteSuccess(BuildContext context, {double alpha = 1}) =>
    siteColors(context).primary.withValues(alpha: alpha);

Color siteDanger(BuildContext context, {double alpha = 1}) =>
    siteColors(context).destructive.withValues(alpha: alpha);

Color siteWarning(BuildContext context, {double alpha = 1}) => siteTone(
      siteColors(context).primary,
      hueShift: 42,
      lightnessDelta: 0.04,
      alpha: alpha,
    );

Color siteInfo(BuildContext context, {double alpha = 1}) => siteTone(
      siteColors(context).primary,
      hueShift: -34,
      saturationScale: 0.9,
      alpha: alpha,
    );

Color siteAccent(BuildContext context, int index, {double alpha = 1}) {
  final cs = siteColors(context);
  final palette = <Color>[
    cs.primary,
    siteWarning(context),
    siteInfo(context),
    cs.destructive,
    siteTone(cs.primary, hueShift: 86, saturationScale: 0.82),
    siteTone(cs.destructive, hueShift: 24, lightnessDelta: 0.04),
    Color.lerp(cs.primary, cs.destructive, 0.4) ?? cs.primary,
    siteTone(cs.secondary, saturationScale: 1.35, lightnessDelta: -0.08),
    siteTone(cs.primary, hueShift: 126, saturationScale: 0.76),
    siteTone(cs.mutedForeground, saturationScale: 1.2),
  ];
  return palette[index % palette.length].withValues(alpha: alpha);
}

Color siteTransparent(BuildContext context) =>
    siteColors(context).background.withValues(alpha: 0);

Color siteShadow(BuildContext context, {double alpha = 0.10}) =>
    siteColors(context).foreground.withValues(alpha: alpha);

BorderRadius siteRadius(BuildContext context, {String size = 'md'}) {
  final theme = siteTheme(context);
  return switch (size) {
    'xs' => theme.borderRadiusXs,
    'sm' => theme.borderRadiusSm,
    'lg' => theme.borderRadiusLg,
    'xl' => theme.borderRadiusXl,
    _ => theme.borderRadiusMd,
  };
}
