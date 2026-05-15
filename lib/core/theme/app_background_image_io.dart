import 'dart:io' as io;

import 'package:flutter/widgets.dart';

import 'app_dashboard_background.dart';
import 'app_theme.dart';

Widget appThemeBackgroundImage(ThemeState themeState, {BoxFit fit = BoxFit.cover}) {
  final path = themeState.backgroundImage.isEmpty
      ? 'assets/images/background.png'
      : themeState.backgroundImage;
  if (themeState.backgroundMode == 'asset' && path == 'assets/images/background.png') {
    return const AppDashboardBackground();
  }
  if (themeState.backgroundMode == 'file' && io.File(path).existsSync()) {
    return Image.file(io.File(path), fit: fit);
  }
  if (themeState.backgroundMode == 'network' && path.startsWith('http')) {
    final url = themeState.useImageProxy ? 'https://images.weserv.nl/?url=$path' : path;
    return Image.network(
      url,
      fit: fit,
      errorBuilder: (_, __, ___) => Image.asset('assets/images/background.png', fit: fit),
    );
  }
  return Image.asset('assets/images/background.png', fit: fit);
}
