import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// 构建自定义 typography（复用）
/// FTileStyle.inherit 用 typography.base 做标题，typography.xs 做副标题
FTypography _customTypography(BuildContext context, double fontSize) {
  final typography = FTheme.of(context).typography;
  return typography.copyWith(
    base: typography.base.copyWith(fontSize: fontSize),
    xs: typography.xs.copyWith(fontSize: fontSize - 1),
  );
}

/// ItemGroup 样式
FItemGroupStyle fItemGroupStyle(
  BuildContext context, {
  double fontSize = 14,
  double borderRadius = 8,
  double dividerWidth = 0.5,
}) {
  final colors = FTheme.of(context).colors;
  final style = FTheme.of(context).style;
  final typography = _customTypography(context, fontSize);
  final effectiveBorderRadius = BorderRadius.circular(borderRadius);

  return FItemGroupStyle(
    dividerColor: FWidgetStateMap.all(colors.border),
    dividerWidth: dividerWidth,
    itemStyle: FItemStyle.inherit(colors: colors, style: style, typography: typography),
    decoration: BoxDecoration(borderRadius: effectiveBorderRadius),
    spacing: 0,
  );
}

/// TileGroup 样式
FTileGroupStyle fTileGroupStyle(
  BuildContext context, {
  double fontSize = 14,
  double borderRadius = 8,
  double dividerWidth = 0.5,
}) {
  final colors = FTheme.of(context).colors;
  final style = FTheme.of(context).style;
  final typography = _customTypography(context, fontSize);
  final effectiveBorderRadius = BorderRadius.circular(borderRadius);

  return FTileGroupStyle(
    decoration: BoxDecoration(borderRadius: effectiveBorderRadius),
    tileStyle: FTileStyle.inherit(
      colors: colors,
      style: style,
      typography: typography,
    ).copyWith(decoration: FWidgetStateMap.all(BoxDecoration(borderRadius: effectiveBorderRadius))),
    dividerColor: FWidgetStateMap.all(colors.border),
    dividerWidth: dividerWidth,
    labelTextStyle: FWidgetStateMap.all(typography.sm.copyWith(color: colors.mutedForeground)),
    descriptionTextStyle: FWidgetStateMap.all(typography.sm.copyWith(color: colors.mutedForeground)),
    errorTextStyle: typography.sm.copyWith(color: colors.destructive),
  );
}

/// PopoverMenu 样式
FPopoverMenuStyle fPopoverMenuStyle(
  BuildContext context, {
  double maxWidth = 160,
  double fontSize = 14,
  double borderRadius = 8,
  double shadowBlur = 10,
  double shadowOffsetY = 2,
  double dividerWidth = 0.5,
}) {
  final effectiveBorderRadius = BorderRadius.circular(borderRadius);

  return FPopoverMenuStyle(
    itemGroupStyle: fItemGroupStyle(
      context,
      fontSize: fontSize,
      borderRadius: borderRadius,
      dividerWidth: dividerWidth,
    ),
    tileGroupStyle: fTileGroupStyle(
      context,
      fontSize: fontSize,
      borderRadius: borderRadius,
      dividerWidth: dividerWidth,
    ),
    decoration: BoxDecoration(
      borderRadius: effectiveBorderRadius,
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: shadowBlur, offset: Offset(0, shadowOffsetY))],
    ),
    maxWidth: maxWidth,
  );
}

/// Header 样式
FHeaderStyle Function(FHeaderStyle) fHeaderStyle(
  BuildContext context, {
  double titleFontSize = 18,
  double actionIconSize = 25,
  double actionSpacing = 8,
}) {
  final colors = FTheme.of(context).colors;
  final typography = FTheme.of(context).typography;

  return (style) => style.copyWith(
    titleTextStyle: typography.xl.copyWith(
      color: colors.foreground,
      fontSize: titleFontSize,
      fontWeight: FontWeight.w600,
      height: 1,
    ),
    actionSpacing: actionSpacing,
    actionStyle: (actionStyle) => actionStyle.copyWith(
      iconStyle: FWidgetStateMap({
        WidgetState.disabled: IconThemeData(color: colors.disable(colors.foreground), size: actionIconSize),
        WidgetState.any: IconThemeData(color: colors.foreground, size: actionIconSize),
      }),
    ),
  );
}

/// Header destructive action 样式
FHeaderActionStyle fDestructiveHeaderActionStyle(
  BuildContext context, {
  double iconSize = 25,
}) {
  final colors = FTheme.of(context).colors;
  final base = FTheme.of(context).headerStyles.nestedStyle.actionStyle;

  return base.copyWith(
    iconStyle: FWidgetStateMap({
      WidgetState.disabled: IconThemeData(color: colors.disable(colors.destructive), size: iconSize),
      WidgetState.any: IconThemeData(color: colors.destructive, size: iconSize),
    }),
  );
}

FSwitchStyle fSwitchStyle(
  BuildContext context, {
  double fontSize = 12,
  Color? activeTrackColor,
  Color? inactiveTrackColor,
  Color? activeThumbColor,
  Color? inactiveThumbColor,
  Color? focusColor,
}) {
  final colors = FTheme.of(context).colors;
  final typography = FTheme.of(context).typography;

  final effectiveTextStyle = typography.sm.copyWith(fontSize: fontSize);
  final labelStyle = FWidgetStateMap.all(effectiveTextStyle);
  final descriptionStyle = FWidgetStateMap.all(effectiveTextStyle.copyWith(color: colors.mutedForeground));
  final errorStyle = effectiveTextStyle.copyWith(color: colors.destructive);

  final effectiveActiveTrack = activeTrackColor ?? colors.primary;
  final effectiveInactiveTrack = inactiveTrackColor ?? colors.border;
  final effectiveActiveThumb = activeThumbColor ?? colors.primaryForeground;
  final effectiveInactiveThumb = inactiveThumbColor ?? colors.mutedForeground;
  final effectiveFocus = focusColor ?? colors.primary.withValues(alpha: 0.2);

  return FSwitchStyle(
    focusColor: effectiveFocus,
    // ← Color，不是 FWidgetStateMap
    trackColor: FWidgetStateMap({
      WidgetState.selected: effectiveActiveTrack,
      WidgetState.disabled: colors.disable(effectiveInactiveTrack),
      WidgetState.any: effectiveInactiveTrack,
    }),
    thumbColor: FWidgetStateMap({
      WidgetState.selected: effectiveActiveThumb,
      WidgetState.disabled: colors.disable(effectiveInactiveThumb),
      WidgetState.any: effectiveInactiveThumb,
    }),
    labelTextStyle: labelStyle,
    descriptionTextStyle: descriptionStyle,
    errorTextStyle: errorStyle,
  );
}
