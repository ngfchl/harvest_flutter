import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest/theme/theme_service.dart';

class BackgroundContainer extends GetView<BackgroundService> {
  final Widget child;

  const BackgroundContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.useBackground.value) return child;

      String image = controller.backgroundImage.value;
      double blur = controller.blur.value;
      double opacity = controller.opacity.value;
      bool useLocal = controller.useLocalBackground.value;
      bool useProxy = controller.useImageProxy.value;

      final proxy = 'https://images.weserv.nl/?url=';

      Widget bg = useLocal && !image.startsWith('http')
          ? Image.file(
              File(image),
              key: ValueKey(image),
              fit: BoxFit.cover,
            )
          : CachedNetworkImage(
              key: ValueKey(image),
              imageUrl: useProxy ? '$proxy$image' : image,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Image.asset("assets/images/background.png", fit: BoxFit.cover),
            );

      return Stack(
        children: [
          /// 背景淡入淡出
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 600),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: SizedBox.expand(
                key: ValueKey(image),
                child: bg,
              ),
            ),
          ),

          /// Blur 模糊层
          if (blur > 0)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: blur,
                  sigmaY: blur,
                ),
                child: Container(
                  color: Colors.transparent, // 透明，不遮挡
                ),
              ),
            ),

          /// 半透明遮罩
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(1 - opacity),
            ),
          ),

          /// 页面内容
          Positioned.fill(child: child),
        ],
      );
    });
  }
}
