import 'package:flutter/material.dart';

class ContinuousGradientText extends StatefulWidget {
  final String text;
  final double fontSize;
  final Duration duration;
  final List<Color>? lightColors;
  final List<Color>? darkColors;

  const ContinuousGradientText({
    super.key,
    required this.text,
    this.fontSize = 16,
    this.duration = const Duration(seconds: 4),
    this.lightColors,
    this.darkColors,
  });

  @override
  State<ContinuousGradientText> createState() => _ContinuousGradientTextState();
}

class _ContinuousGradientTextState extends State<ContinuousGradientText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<Color> _colors;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = Theme.of(context).brightness;
    _colors = brightness == Brightness.dark
        ? widget.darkColors ??
        const [
          Color(0xFF16A085),
          Color(0xFF2980B9),
          Color(0xFFD35400),
          Color(0xFFC0392B),
          Color(0xFF8E44AD),
          Color(0xFFF39C12),
          Color(0xFF27AE60),
          Color(0xFF2C3E50),
        ]
        : widget.lightColors ??
        const [
          Color(0xFF1ABC9C),
          Color(0xFF3498DB),
          Color(0xFFE67E22),
          Color(0xFFE74C3C),
          Color(0xFF9B59B6),
          Color(0xFFF1C40F),
          Color(0xFF2ECC71),
          Color(0xFF34495E),
        ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final double maxWidth = constraints.maxWidth > 0 ? constraints.maxWidth : 200;

      return SizedBox(
        width: maxWidth,
        child: ClipRect(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final offset = _controller.value * maxWidth;

              return ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    colors: [
                      ..._colors,
                      ..._colors, // 重复一遍颜色数组，保证无缝
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    tileMode: TileMode.repeated, // 无限重复
                  ).createShader(
                      Rect.fromLTWH(-offset, 0, bounds.width + offset, bounds.height));
                },
                child: child,
              );
            },
            child: Text(
              widget.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    });
  }
}
