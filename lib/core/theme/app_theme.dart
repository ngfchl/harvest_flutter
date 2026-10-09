import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'theme_presets.dart';

class ThemeState {
  final String baseScheme;
  final String accent;
  final ThemeMode mode;
  final double radius;
  final String density;
  final double scaling;

  const ThemeState({
    this.baseScheme = 'neutral',
    this.accent = 'sky',
    this.mode = ThemeMode.system,
    this.radius = 0.5,
    this.density = 'default',
    this.scaling = 1.0,
  });

  AppTheme get theme => AppThemes.fromState(this);

  Density get shadcnDensity => AppThemeOptions.densityValue(density);

  AdaptiveScaling get adaptiveScaling => AdaptiveScaling(scaling);

  ThemeData get shadcnLight => _themeData(false);

  ThemeData get shadcnDark => _themeData(true);

  ThemeData _themeData(bool dark) {
    return ThemeData(
      colorScheme: AppThemeOptions.colorScheme(baseScheme, accent, dark),
      radius: radius,
      density: shadcnDensity,
    );
  }

  ThemeState copyWith({
    String? baseScheme,
    String? accent,
    ThemeMode? mode,
    double? radius,
    String? density,
    double? scaling,
  }) {
    return ThemeState(
      baseScheme: baseScheme ?? this.baseScheme,
      accent: accent ?? this.accent,
      mode: mode ?? this.mode,
      radius: radius ?? this.radius,
      density: density ?? this.density,
      scaling: scaling ?? this.scaling,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseScheme': baseScheme,
      'accent': accent,
      'mode': mode.name,
      'radius': radius,
      'density': density,
      'scaling': scaling,
    };
  }

  factory ThemeState.fromJson(Map<String, dynamic> json) {
    final modeValue = json['mode'];
    final mode = modeValue is int
        ? ThemeMode.values[modeValue.clamp(0, ThemeMode.values.length - 1)]
        : switch (modeValue?.toString()) {
            'light' => ThemeMode.light,
            'dark' => ThemeMode.dark,
            _ => ThemeMode.system,
          };
    return ThemeState(
      baseScheme: AppThemeOptions.normalizeBase(json['baseScheme'] ?? json['theme'] ?? json['name']),
      accent: AppThemeOptions.normalizeAccent(json['accent'] ?? json['theme'] ?? json['name']),
      mode: mode,
      radius: (json['radius'] as num?)?.toDouble() ?? 0.5,
      density: AppThemeOptions.normalizeDensity(json['density']),
      scaling: (json['scaling'] as num?)?.toDouble() ?? 1.0,
    );
  }
}

class AppTheme {
  final String name;
  final String label;
  final Color seedColor;
  final String baseScheme;
  final String accent;

  const AppTheme({
    required this.name,
    required this.label,
    required this.seedColor,
    required this.baseScheme,
    required this.accent,
  });

  ThemeData get shadcnLight => ThemeData(
    colorScheme: AppThemeOptions.colorScheme(baseScheme, accent, false),
    radius: 0.5,
    density: Density.defaultDensity,
  );

  ThemeData get shadcnDark => ThemeData(
    colorScheme: AppThemeOptions.colorScheme(baseScheme, accent, true),
    radius: 0.5,
    density: Density.defaultDensity,
  );

  Map<String, dynamic> toJson() {
    return {'name': name, 'baseScheme': baseScheme, 'accent': accent};
  }

  factory AppTheme.fromJson(Map<String, dynamic> json) {
    return AppThemes.byName(json['name']?.toString());
  }
}
