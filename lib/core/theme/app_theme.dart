import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import 'theme_presets.dart';

class ThemeState {
  final String baseScheme;
  final String accent;
  final shadcn.ThemeMode mode;
  final double radius;
  final String density;
  final double scaling;
  final double surfaceOpacity;
  final double surfaceBlur;

  const ThemeState({
    this.baseScheme = 'stone',
    this.accent = 'rose',
    this.mode = shadcn.ThemeMode.system,
    this.radius = 1.5,
    this.density = 'spacious',
    this.scaling = 1.15,
    this.surfaceOpacity = 0.7,
    this.surfaceBlur = 0.0,
  });

  AppTheme get theme => AppThemes.fromState(this);

  shadcn.Density get shadcnDensity => AppThemeOptions.densityValue(density);

  shadcn.AdaptiveScaling get adaptiveScaling => shadcn.AdaptiveScaling(scaling);

  shadcn.ThemeData get shadcnLight => _themeData(false);

  shadcn.ThemeData get shadcnDark => _themeData(true);

  shadcn.ThemeData _themeData(bool dark) {
    return shadcn.ThemeData(
      colorScheme: AppThemeOptions.colorScheme(baseScheme, accent, dark),
      radius: radius,
      density: shadcnDensity,
      surfaceOpacity: surfaceOpacity,
      surfaceBlur: surfaceBlur,
    );
  }

  ThemeData materialTheme(Brightness brightness) {
    final shadcnTheme = brightness == Brightness.dark ? shadcnDark : shadcnLight;
    final cs = shadcnTheme.colorScheme;
    final materialScheme = ColorScheme.fromSeed(
      seedColor: cs.primary,
      brightness: brightness,
      surface: cs.background,
      primary: cs.primary,
      secondary: cs.secondary,
      error: cs.destructive,
    );
    final md = BorderRadius.circular(shadcnTheme.radiusMd);
    final lg = BorderRadius.circular(shadcnTheme.radiusLg);
    final sm = BorderRadius.circular(shadcnTheme.radiusSm);
    return ThemeData.from(colorScheme: materialScheme).copyWith(
      scaffoldBackgroundColor: cs.background,
      dialogTheme: DialogThemeData(
        backgroundColor: cs.background,
        shape: RoundedRectangleBorder(borderRadius: lg),
      ),
      cardTheme: CardThemeData(
        color: cs.card,
        shape: RoundedRectangleBorder(borderRadius: lg),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: md),
        enabledBorder: OutlineInputBorder(
          borderRadius: md,
          borderSide: BorderSide(color: cs.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: md,
          borderSide: BorderSide(color: cs.ring),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: md)),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: md)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: sm)),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: sm),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(shadcnTheme.radiusLg)),
        ),
      ),
    );
  }

  ThemeState copyWith({
    String? baseScheme,
    String? accent,
    shadcn.ThemeMode? mode,
    double? radius,
    String? density,
    double? scaling,
    double? surfaceOpacity,
    double? surfaceBlur,
  }) {
    return ThemeState(
      baseScheme: baseScheme ?? this.baseScheme,
      accent: accent ?? this.accent,
      mode: mode ?? this.mode,
      radius: radius ?? this.radius,
      density: density ?? this.density,
      scaling: scaling ?? this.scaling,
      surfaceOpacity: surfaceOpacity ?? this.surfaceOpacity,
      surfaceBlur: surfaceBlur ?? this.surfaceBlur,
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
      'surfaceOpacity': surfaceOpacity,
      'surfaceBlur': surfaceBlur,
    };
  }

  factory ThemeState.fromJson(Map<String, dynamic> json) {
    final modeValue = json['mode'];
    final mode = modeValue is int
        ? shadcn.ThemeMode.values[modeValue.clamp(0, shadcn.ThemeMode.values.length - 1)]
        : switch (modeValue?.toString()) {
            'light' => shadcn.ThemeMode.light,
            'dark' => shadcn.ThemeMode.dark,
            _ => shadcn.ThemeMode.system,
          };
    return ThemeState(
      baseScheme: AppThemeOptions.normalizeBase(json['baseScheme'] ?? json['theme'] ?? json['name']),
      accent: AppThemeOptions.normalizeAccent(json['accent'] ?? json['theme'] ?? json['name']),
      mode: mode,
      radius: (json['radius'] as num?)?.toDouble() ?? 1.5,
      density: AppThemeOptions.normalizeDensity(json['density']),
      scaling: (json['scaling'] as num?)?.toDouble() ?? 1.15,
      surfaceOpacity: (json['surfaceOpacity'] as num?)?.toDouble() ?? 0.7,
      surfaceBlur: (json['surfaceBlur'] as num?)?.toDouble() ?? 0.0,
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

  shadcn.ThemeData get shadcnLight => shadcn.ThemeData(
    colorScheme: AppThemeOptions.colorScheme(baseScheme, accent, false),
    radius: 1.5,
    density: shadcn.Density.spaciousDensity,
    surfaceOpacity: 0.7,
  );

  shadcn.ThemeData get shadcnDark => shadcn.ThemeData(
    colorScheme: AppThemeOptions.colorScheme(baseScheme, accent, true),
    radius: 1.5,
    density: shadcn.Density.spaciousDensity,
    surfaceOpacity: 0.7,
  );

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'baseScheme': baseScheme,
      'accent': accent,
    };
  }

  factory AppTheme.fromJson(Map<String, dynamic> json) {
    return AppThemes.byName(json['name']?.toString());
  }
}
