import 'package:harvest/core/theme/theme_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import 'app_theme.dart';
import 'theme_presets.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeState build() {
    return ThemeStorage.getPersistedStateSync();
  }

  Future<void> _persist() => ThemeStorage.saveState(state);

  void setTheme(AppTheme theme) {
    state = state.copyWith(
      baseScheme: theme.baseScheme,
      accent: theme.accent,
    );
    _persist();
  }

  void setMode(shadcn.ThemeMode mode) {
    state = state.copyWith(mode: mode);
    _persist();
  }

  void setBaseScheme(String baseScheme) {
    state = state.copyWith(baseScheme: AppThemeOptions.normalizeBase(baseScheme));
    _persist();
  }

  void setAccent(String accent) {
    state = state.copyWith(accent: AppThemeOptions.normalizeAccent(accent));
    _persist();
  }

  void setRadius(double radius) {
    state = state.copyWith(radius: radius);
    _persist();
  }

  void setDensity(String density) {
    state = state.copyWith(density: AppThemeOptions.normalizeDensity(density));
    _persist();
  }

  void setScaling(double scaling) {
    state = state.copyWith(scaling: scaling);
    _persist();
  }

  void setSurfaceOpacity(double surfaceOpacity) {
    state = state.copyWith(surfaceOpacity: surfaceOpacity);
    _persist();
  }

  void setSurfaceBlur(double surfaceBlur) {
    state = state.copyWith(surfaceBlur: surfaceBlur);
    _persist();
  }

  void setUseBackground(bool useBackground) {
    state = state.copyWith(useBackground: useBackground);
    _persist();
  }

  void setManageBackgroundImages(bool manageBackgroundImages) {
    state = state.copyWith(manageBackgroundImages: manageBackgroundImages);
    _persist();
  }

  void setBackgroundMode(String backgroundMode) {
    state = state.copyWith(backgroundMode: backgroundMode);
    _persist();
  }

  void setBackgroundImage(String backgroundImage) {
    state = state.copyWith(backgroundImage: backgroundImage);
    _persist();
  }

  void setUseImageProxy(bool useImageProxy) {
    state = state.copyWith(useImageProxy: useImageProxy);
    _persist();
  }


  void reset() {
    state = const ThemeState();
    _persist();
  }
}
