import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

class GlassWidget extends StatelessWidget {
  const GlassWidget({Key? key, required Widget this.child}) : super(key: key);

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Lottie.asset(
        //   StringUtils.getLottieByName('rJoSLquA8J'),
        //   repeat: true,
        //   fit: BoxFit.fill,
        // ),

        GlassContainer(
          height: double.infinity,
          width: double.infinity,
          blur: 1,
          color: Colors.white24,
          // gradient: LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          //   colors: [
          //     Colors.green.withOpacity(0.5),
          //     Colors.blueGrey.withOpacity(0.6),
          //     Colors.grey.withOpacity(0.4),
          //     Colors.blue.withOpacity(0.6),
          //   ],
          // ),
          //--code to remove border
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
