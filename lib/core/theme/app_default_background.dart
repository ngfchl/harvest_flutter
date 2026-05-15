import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

class AppDefaultBackground extends StatefulWidget {
  const AppDefaultBackground({super.key});

  @override
  State<AppDefaultBackground> createState() => _AppDefaultBackgroundState();
}

class _AppDefaultBackgroundState extends State<AppDefaultBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final cyan = _tone(cs.primary, hueShift: isDark ? 18 : 10, saturationScale: 1.12);
    final green = _tone(cs.primary, hueShift: 120, saturationScale: 0.98);
    final blue = _tone(cs.primary, hueShift: -34, saturationScale: 1.04);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        painter: _AppDefaultBackgroundPainter(
          tick: _controller.value,
          background: cs.background,
          panelSoft: cs.muted,
          cyan: cyan,
          green: green,
          blue: blue,
          isDark: isDark,
        ),
      ),
    );
  }
}

Color _tone(
  Color color, {
  double hueShift = 0,
  double saturationScale = 1,
  double lightnessDelta = 0,
}) {
  final hsl = HSLColor.fromColor(color);
  return hsl
      .withHue((hsl.hue + hueShift) % 360)
      .withSaturation((hsl.saturation * saturationScale).clamp(0.22, 0.90))
      .withLightness((hsl.lightness + lightnessDelta).clamp(0.30, 0.70))
      .toColor();
}

class _AppDefaultBackgroundPainter extends CustomPainter {
  final double tick;
  final Color background;
  final Color panelSoft;
  final Color cyan;
  final Color green;
  final Color blue;
  final bool isDark;

  const _AppDefaultBackgroundPainter({
    required this.tick,
    required this.background,
    required this.panelSoft,
    required this.cyan,
    required this.green,
    required this.blue,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);

    final topWash = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          blue.withValues(alpha: isDark ? 0.34 : 0.20),
          panelSoft.withValues(alpha: isDark ? 0 : 0.08),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, topWash);

    final sideWash = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          cyan.withValues(alpha: isDark ? 0.08 : 0.18),
          background.withValues(alpha: 0),
          blue.withValues(alpha: isDark ? 0.07 : 0.15),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sideWash);

    _drawGrid(canvas, size);
    _drawDigits(canvas, size);
    _drawTraces(canvas, size);
    _drawCorners(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final fine = Paint()
      ..color = blue.withValues(alpha: isDark ? 0.10 : 0.18)
      ..strokeWidth = 0.45;
    for (double x = 0; x <= size.width; x += 22) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), fine);
    }
    for (double y = 0; y <= size.height; y += 22) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), fine);
    }

    final major = Paint()
      ..color = cyan.withValues(alpha: isDark ? 0.12 : 0.28)
      ..strokeWidth = 0.75;
    for (double x = 0; x <= size.width; x += 88) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), major);
    }
    for (double y = 0; y <= size.height; y += 88) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), major);
    }
  }

  void _drawDigits(Canvas canvas, Size size) {
    final phase = tick * 64;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final columns = (size.width / 27).ceil() + 1;
    final rows = (size.height / 22).ceil() + 1;
    for (var column = 0; column < columns; column++) {
      final x = column * 27.0 + (column.isEven ? 8 : 18);
      final verticalShift = (phase * (0.72 + (column % 5) * 0.18) + column * 9) % 22;
      final highlight = (phase + column * 7) % rows;
      for (var row = -1; row < rows; row++) {
        final y = row * 22.0 + verticalShift;
        if (y < -22 || y > size.height + 22) continue;
        final distance = ((row - highlight).abs() % rows).toDouble();
        final pulse = math.max(0.0, 1.0 - distance / 5.5);
        final alpha = ((isDark ? 0.035 : 0.075) + pulse * (isDark ? 0.12 : 0.22)) *
            _edgeFade(x, size.width);
        if (alpha <= (isDark ? 0.006 : 0.018)) continue;
        final digit = ((column * 7 + row * 3 + phase.floor()) % 10).abs();
        textPainter.text = TextSpan(
          text: '$digit',
          style: TextStyle(
            color: (column.isEven ? cyan : green).withValues(alpha: alpha),
            fontSize: (isDark ? 12 : 13) + pulse * (isDark ? 3 : 4),
            fontWeight: pulse > 0.65 ? FontWeight.w800 : FontWeight.w600,
            height: 1,
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x, y));
      }
    }
  }

  double _edgeFade(double x, double width) {
    final distanceToEdge = math.min(x, width - x).clamp(0.0, 180.0);
    final edge = distanceToEdge / 180.0;
    final middle = (1 - ((x / width) - 0.5).abs() * 1.55).clamp(0.36, 1.0);
    return (0.45 + edge * 0.55) * middle;
  }

  void _drawTraces(Canvas canvas, Size size) {
    final trace = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = cyan.withValues(alpha: isDark ? 0.18 : 0.34);
    final path = Path()
      ..moveTo(size.width * 0.04, size.height * 0.18)
      ..lineTo(size.width * 0.18, size.height * 0.18)
      ..lineTo(size.width * 0.23, size.height * 0.12)
      ..lineTo(size.width * 0.42, size.height * 0.12)
      ..lineTo(size.width * 0.48, size.height * 0.22)
      ..lineTo(size.width * 0.62, size.height * 0.22);
    canvas.drawPath(path, trace);

    final lower = Path()
      ..moveTo(size.width * 0.07, size.height * 0.72)
      ..lineTo(size.width * 0.18, size.height * 0.72)
      ..lineTo(size.width * 0.23, size.height * 0.64)
      ..lineTo(size.width * 0.37, size.height * 0.64)
      ..lineTo(size.width * 0.42, size.height * 0.76)
      ..lineTo(size.width * 0.57, size.height * 0.76)
      ..lineTo(size.width * 0.62, size.height * 0.68)
      ..lineTo(size.width * 0.82, size.height * 0.68);
    canvas.drawPath(lower, trace);
  }

  void _drawCorners(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = cyan.withValues(alpha: isDark ? 0.24 : 0.42);
    const inset = 20.0;
    const length = 54.0;
    final paths = [
      Path()..moveTo(inset, inset + length)..lineTo(inset, inset)..lineTo(inset + length, inset),
      Path()
        ..moveTo(size.width - inset - length, inset)
        ..lineTo(size.width - inset, inset)
        ..lineTo(size.width - inset, inset + length),
      Path()
        ..moveTo(inset, size.height - inset - length)
        ..lineTo(inset, size.height - inset)
        ..lineTo(inset + length, size.height - inset),
      Path()
        ..moveTo(size.width - inset - length, size.height - inset)
        ..lineTo(size.width - inset, size.height - inset)
        ..lineTo(size.width - inset, size.height - inset - length),
    ];
    for (final path in paths) {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AppDefaultBackgroundPainter oldDelegate) =>
      oldDelegate.tick != tick ||
      oldDelegate.background != background ||
      oldDelegate.panelSoft != panelSoft ||
      oldDelegate.cyan != cyan ||
      oldDelegate.green != green ||
      oldDelegate.blue != blue ||
      oldDelegate.isDark != isDark;
}
