import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

class GlassWidget extends StatelessWidget {
  const GlassWidget({super.key, required Widget this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GlassContainer(
          height: double.infinity,
          width: double.infinity,
          blur: 1,
          color: const Color(0xFFF2F3F8),
          border: const Border.fromBorderSide(BorderSide.none),
          shadowStrength: 5,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(2),
          shadowColor: Colors.white.withOpacity(0.24),
          child: child,
        ),
      ],
    );
  }
}
