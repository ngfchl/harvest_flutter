import 'package:harvest/core/utils/ui/responsive.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

ThemeData siteTheme(BuildContext context) => Theme.of(context);

ColorScheme siteColors(BuildContext context) => siteTheme(context).colorScheme;

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

Color siteSuccess(BuildContext context, {double alpha = 1}) => siteColors(context).primary.withValues(alpha: alpha);

Color siteDanger(BuildContext context, {double alpha = 1}) => siteColors(context).destructive.withValues(alpha: alpha);

Color siteWarning(BuildContext context, {double alpha = 1}) =>
    siteTone(siteColors(context).primary, hueShift: 42, lightnessDelta: 0.04, alpha: alpha);

Color siteInfo(BuildContext context, {double alpha = 1}) =>
    siteTone(siteColors(context).primary, hueShift: -34, saturationScale: 0.9, alpha: alpha);

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

Color siteTransparent(BuildContext context) => siteColors(context).background.withValues(alpha: 0);

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

class SiteCardTokens {
  final BuildContext context;
  final ThemeData theme;
  final bool compact;
  final double scale;

  SiteCardTokens._({required this.context, required this.theme, required this.compact, required this.scale});

  factory SiteCardTokens.of(BuildContext context, {bool? compact}) {
    final theme = siteTheme(context);
    final compactLayout = compact ?? MediaQuery.sizeOf(context).width < kMobileBreakpoint;
    final densityScale = (theme.density.baseGap / 8).clamp(0.88, 1.14);
    final visualScale = (theme.scaling * densityScale).clamp(0.84, 1.18);
    return SiteCardTokens._(
      context: context,
      theme: theme,
      compact: compactLayout,
      scale: visualScale * (compactLayout ? 0.94 : 1.0),
    );
  }

  ColorScheme get colors => theme.colorScheme;

  bool get isDark => colors.brightness == Brightness.dark;

  double size(num value) => value.toDouble() * scale;

  EdgeInsets edgeFromLTRB(double left, double top, double right, double bottom) {
    return EdgeInsets.fromLTRB(size(left), size(top), size(right), size(bottom));
  }

  EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) {
    return EdgeInsets.symmetric(horizontal: size(horizontal), vertical: size(vertical));
  }

  BorderRadius get cardRadius => siteRadius(context, size: 'lg');

  BorderRadius get panelRadius => siteRadius(context, size: 'md');

  BorderRadius get tileRadius => siteRadius(context, size: 'lg');

  BorderRadius get chipRadius => siteRadius(context, size: 'xs');

  BorderRadius get pillRadius => siteRadius(context, size: 'xl');

  Color get cardColor =>
      isDark ? Color.alphaBlend(colors.muted.withValues(alpha: 0.09), colors.background) : colors.card;

  Color get borderColor => isDark ? colors.border.withValues(alpha: 0.58) : colors.border.withValues(alpha: 0.86);

  Color get dividerColor => isDark ? colors.border.withValues(alpha: 0.38) : colors.border.withValues(alpha: 0.72);

  BoxDecoration cardDecoration({double borderWidth = 0.8, double shadowStrength = 1}) {
    return BoxDecoration(
      color: cardColor,
      borderRadius: cardRadius,
      border: Border.all(color: borderColor, width: borderWidth),
      boxShadow: cardShadows(strength: shadowStrength),
    );
  }

  List<BoxShadow> cardShadows({double strength = 1}) {
    if (isDark) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.20 * strength),
          blurRadius: size(22),
          offset: Offset(0, size(8)),
          spreadRadius: -size(4),
        ),
      ];
    }
    return [
      BoxShadow(
        color: siteShadow(context, alpha: 0.065 * strength),
        blurRadius: size(22),
        offset: Offset(0, size(8)),
        spreadRadius: -size(4),
      ),
      BoxShadow(
        color: siteShadow(context, alpha: 0.025 * strength),
        blurRadius: size(5),
        offset: Offset(0, size(2)),
      ),
    ];
  }
}
