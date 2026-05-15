import 'package:flutter/material.dart';

import 'background_image_models.dart';

class BackgroundPreview extends StatelessWidget {
  final ManagedBackgroundImage image;

  const BackgroundPreview({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    if (image.isNetwork) {
      return Image.network(
        image.path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset('assets/images/background.png', fit: BoxFit.cover),
      );
    }
    return Image.asset('assets/images/background.png', fit: BoxFit.cover);
  }
}
