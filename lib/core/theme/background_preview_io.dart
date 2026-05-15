import 'dart:io' as io;

import 'package:flutter/widgets.dart';
import 'package:harvest/core/theme/app_dashboard_background.dart';
import 'package:harvest/core/theme/background_image_models.dart';

class BackgroundPreview extends StatelessWidget {
  final ManagedBackgroundImage image;

  const BackgroundPreview({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    if (image.isAsset) return const AppDashboardBackground();
    if (image.isNetwork) {
      return Image.network(
        image.path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const AppDashboardBackground(),
      );
    }
    return Image.file(
      io.File(image.path),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const AppDashboardBackground(),
    );
  }
}
