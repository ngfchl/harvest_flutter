import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import 'app_theme.dart';

class AppThemeOption<T> {
  final String id;
  final String label;
  final T value;

  const AppThemeOption({
    required this.id,
    required this.label,
    required this.value,
  });
}

class AppThemeOptions {
  static const baseSchemes = [
    AppThemeOption(id: 'slate', label: 'Slate', value: 'slate'),
    AppThemeOption(id: 'zinc', label: 'Zinc', value: 'zinc'),
    AppThemeOption(id: 'gray', label: 'Gray', value: 'gray'),
    AppThemeOption(id: 'neutral', label: 'Neutral', value: 'neutral'),
    AppThemeOption(id: 'stone', label: 'Stone', value: 'stone'),
  ];

  static const accents = [
    AppThemeOption<Color?>(id: 'base', label: 'Base', value: null),
    AppThemeOption(id: 'slate', label: 'Slate', value: shadcn.Colors.slate),
    AppThemeOption(id: 'gray', label: 'Gray', value: shadcn.Colors.gray),
    AppThemeOption(id: 'zinc', label: 'Zinc', value: shadcn.Colors.zinc),
    AppThemeOption(
      id: 'neutral',
      label: 'Neutral',
      value: shadcn.Colors.neutral,
    ),
    AppThemeOption(id: 'stone', label: 'Stone', value: shadcn.Colors.stone),
    AppThemeOption(id: 'red', label: 'Red', value: shadcn.Colors.red),
    AppThemeOption(id: 'orange', label: 'Orange', value: shadcn.Colors.orange),
    AppThemeOption(id: 'amber', label: 'Amber', value: shadcn.Colors.amber),
    AppThemeOption(id: 'yellow', label: 'Yellow', value: shadcn.Colors.yellow),
    AppThemeOption(id: 'lime', label: 'Lime', value: shadcn.Colors.lime),
    AppThemeOption(id: 'green', label: 'Green', value: shadcn.Colors.green),
    AppThemeOption(
      id: 'emerald',
      label: 'Emerald',
      value: shadcn.Colors.emerald,
    ),
    AppThemeOption(id: 'teal', label: 'Teal', value: shadcn.Colors.teal),
    AppThemeOption(id: 'cyan', label: 'Cyan', value: shadcn.Colors.cyan),
    AppThemeOption(id: 'sky', label: 'Sky', value: shadcn.Colors.sky),
    AppThemeOption(id: 'blue', label: 'Blue', value: shadcn.Colors.blue),
    AppThemeOption(id: 'indigo', label: 'Indigo', value: shadcn.Colors.indigo),
    AppThemeOption(id: 'violet', label: 'Violet', value: shadcn.Colors.violet),
    AppThemeOption(id: 'purple', label: 'Purple', value: shadcn.Colors.purple),
    AppThemeOption(
      id: 'fuchsia',
      label: 'Fuchsia',
      value: shadcn.Colors.fuchsia,
    ),
    AppThemeOption(id: 'pink', label: 'Pink', value: shadcn.Colors.pink),
    AppThemeOption(id: 'rose', label: 'Rose', value: shadcn.Colors.rose),
  ];

  static const densities = [
    AppThemeOption(
      id: 'reduced',
      label: 'Reduced',
      value: shadcn.Density.reducedDensity,
    ),
    AppThemeOption(
      id: 'default',
      label: 'Default',
      value: shadcn.Density.defaultDensity,
    ),
    AppThemeOption(
      id: 'spacious',
      label: 'Spacious',
      value: shadcn.Density.spaciousDensity,
    ),
  ];

  static const radiusOptions = [
    AppThemeOption(id: 'sharp', label: 'Sharp', value: 0.0),
    AppThemeOption(id: 'subtle', label: 'Subtle', value: 0.25),
    AppThemeOption(id: 'default', label: 'Default', value: 0.5),
    AppThemeOption(id: 'rounded', label: 'Rounded', value: 0.75),
    AppThemeOption(id: 'pill', label: 'Pill', value: 1.5),
  ];

  static const scalingOptions = [
    AppThemeOption(id: 'compact', label: 'Compact', value: 0.85),
    AppThemeOption(id: 'default', label: 'Default', value: 1.0),
    AppThemeOption(id: 'large', label: 'Large', value: 1.15),
  ];

  static String normalizeBase(Object? value) {
    final id = value?.toString();
    return baseSchemes.any((option) => option.id == id) ? id! : 'neutral';
  }

  static String normalizeAccent(Object? value) {
    final id = value?.toString();
    return accents.any((option) => option.id == id) ? id! : 'sky';
  }

  static String normalizeDensity(Object? value) {
    final id = value?.toString();
    return densities.any((option) => option.id == id) ? id! : 'default';
  }

  static shadcn.Density densityValue(String id) {
    return densities
        .firstWhere(
          (option) => option.id == id,
          orElse: () =>
              densities.firstWhere((option) => option.id == 'default'),
        )
        .value;
  }

  static Color accentColor(String id) {
    return accents
            .firstWhere(
              (option) => option.id == id,
              orElse: () => accents.firstWhere((option) => option.id == 'sky'),
            )
            .value ??
        shadcn.Colors.stone;
  }

  static shadcn.ColorScheme colorScheme(
    String baseId,
    String accentId,
    bool dark,
  ) {
    final base = _baseColorScheme(normalizeBase(baseId), dark);
    final accent = accents
        .firstWhere(
          (option) => option.id == normalizeAccent(accentId),
          orElse: () => accents.last,
        )
        .value;
    return accent == null ? base : base.recolor(accent);
  }

  static shadcn.ColorScheme _baseColorScheme(String id, bool dark) {
    return switch (id) {
      'slate' =>
        dark ? shadcn.ColorSchemes.darkSlate : shadcn.ColorSchemes.lightSlate,
      'zinc' =>
        dark ? shadcn.ColorSchemes.darkZinc : shadcn.ColorSchemes.lightZinc,
      'gray' =>
        dark ? shadcn.ColorSchemes.darkGray : shadcn.ColorSchemes.lightGray,
      'neutral' =>
        dark
            ? shadcn.ColorSchemes.darkNeutral
            : shadcn.ColorSchemes.lightNeutral,
      'stone' =>
        dark ? shadcn.ColorSchemes.darkStone : shadcn.ColorSchemes.lightStone,
      _ =>
        dark
            ? shadcn.ColorSchemes.darkNeutral
            : shadcn.ColorSchemes.lightNeutral,
    };
  }
}

class AppThemes {
  static const sky = AppTheme(
    name: 'sky',
    label: 'Sky',
    seedColor: Color(0xFF0EA5E9),
    baseScheme: 'neutral',
    accent: 'sky',
  );

  static const blue = AppTheme(
    name: 'blue',
    label: 'Blue',
    seedColor: Color(0xFF3B82F6),
    baseScheme: 'slate',
    accent: 'blue',
  );

  static const yellow = AppTheme(
    name: 'yellow',
    label: 'Yellow',
    seedColor: Color(0xFFEAB308),
    baseScheme: 'stone',
    accent: 'yellow',
  );

  static const rose = AppTheme(
    name: 'rose',
    label: 'Rose',
    seedColor: Color(0xFFE11D48),
    baseScheme: 'stone',
    accent: 'rose',
  );

  static const green = AppTheme(
    name: 'green',
    label: 'Green',
    seedColor: Color(0xFF22C55E),
    baseScheme: 'zinc',
    accent: 'green',
  );

  static const orange = AppTheme(
    name: 'orange',
    label: 'Orange',
    seedColor: Color(0xFFF97316),
    baseScheme: 'stone',
    accent: 'orange',
  );

  static const violet = AppTheme(
    name: 'violet',
    label: 'Violet',
    seedColor: Color(0xFF8B5CF6),
    baseScheme: 'slate',
    accent: 'violet',
  );

  static const red = AppTheme(
    name: 'red',
    label: 'Red',
    seedColor: Color(0xFFEF4444),
    baseScheme: 'neutral',
    accent: 'red',
  );

  static const zinc = AppTheme(
    name: 'zinc',
    label: 'Zinc',
    seedColor: Color(0xFF71717A),
    baseScheme: 'zinc',
    accent: 'base',
  );

  static const list = [
    sky,
    blue,
    yellow,
    rose,
    green,
    orange,
    violet,
    red,
    zinc,
  ];

  static AppTheme byName(String? name) {
    return list.firstWhere((theme) => theme.name == name, orElse: () => sky);
  }

  static AppTheme fromState(ThemeState state) {
    return list.firstWhere(
      (theme) =>
          theme.baseScheme == state.baseScheme && theme.accent == state.accent,
      orElse: () => AppTheme(
        name: '${state.baseScheme}-${state.accent}',
        label: '${state.baseScheme}/${state.accent}',
        seedColor: AppThemeOptions.accentColor(state.accent),
        baseScheme: state.baseScheme,
        accent: state.accent,
      ),
    );
  }
}
