import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

class AppDashboardBackground extends StatefulWidget {
  const AppDashboardBackground({super.key});

  @override
  State<AppDashboardBackground> createState() => _AppDashboardBackgroundState();
}

class _AppDashboardBackgroundState extends State<AppDashboardBackground>
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
    final accent = cs.primary;
    final cyan = _tone(accent, hueShift: isDark ? 18 : 10, saturationScale: 1.12);
    final green = _tone(accent, hueShift: 120, saturationScale: 0.98);
    final blue = _tone(accent, hueShift: -34, saturationScale: 1.04);
    return ColoredBox(
      color: cs.background,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _DashboardBackgroundPainter(
            tick: _controller.value,
            isDark: isDark,
            background: cs.background,
            panelSoft: cs.muted,
            cyan: cyan,
            green: green,
            blue: blue,
            scale: shadcn.Theme.of(context).scaling,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  static Color _tone(
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
}

class _DashboardBackgroundPainter extends CustomPainter {
  final double tick;
  final bool isDark;
  final Color background;
  final Color panelSoft;
  final Color cyan;
  final Color green;
  final Color blue;
  final double scale;

  const _DashboardBackgroundPainter({
    required this.tick,
    required this.isDark,
    required this.background,
    required this.panelSoft,
    required this.cyan,
    required this.green,
    required this.blue,
    required this.scale,
  });

  double size(num value) => value * scale;
  double font(num value) => value * scale;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final topWash = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          blue.withValues(alpha: isDark ? 0.34 : 0.20),
          panelSoft.withValues(alpha: isDark ? 0 : 0.08),
        ],
      ).createShader(Offset.zero & canvasSize);
    canvas.drawRect(Offset.zero & canvasSize, topWash);

    final sideWash = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          cyan.withValues(alpha: isDark ? 0.08 : 0.18),
          background.withValues(alpha: 0),
          blue.withValues(alpha: isDark ? 0.07 : 0.15),
        ],
      ).createShader(Offset.zero & canvasSize);
    canvas.drawRect(Offset.zero & canvasSize, sideWash);

    final fineGridPaint = Paint()
      ..color = blue.withValues(alpha: isDark ? 0.10 : 0.18)
      ..strokeWidth = 0.45;
    final fineStep = size(22);
    for (double x = 0; x <= canvasSize.width; x += fineStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, canvasSize.height), fineGridPaint);
    }
    for (double y = 0; y <= canvasSize.height; y += fineStep) {
      canvas.drawLine(Offset(0, y), Offset(canvasSize.width, y), fineGridPaint);
    }

    final majorGridPaint = Paint()
      ..color = cyan.withValues(alpha: isDark ? 0.12 : 0.28)
      ..strokeWidth = 0.75;
    final majorStep = size(88);
    for (double x = 0; x <= canvasSize.width; x += majorStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, canvasSize.height), majorGridPaint);
    }
    for (double y = 0; y <= canvasSize.height; y += majorStep) {
      canvas.drawLine(Offset(0, y), Offset(canvasSize.width, y), majorGridPaint);
    }

    final scanPaint = Paint()
      ..color = cyan.withValues(alpha: isDark ? 0.028 : 0.060)
      ..strokeWidth = 0.5;
    for (double y = size(3); y <= canvasSize.height; y += size(6)) {
      canvas.drawLine(Offset(0, y), Offset(canvasSize.width, y), scanPaint);
    }

    _drawJumpingDigits(canvas, canvasSize);
    _drawCircuitTraces(canvas, canvasSize);
    _drawCornerBrackets(canvas, canvasSize);
  }

  void _drawJumpingDigits(Canvas canvas, Size canvasSize) {
    final columnStep = size(27);
    final rowStep = size(22);
    final phase = tick * size(64);
    final columns = (canvasSize.width / columnStep).ceil() + 1;
    final rows = (canvasSize.height / rowStep).ceil() + 1;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var column = 0; column < columns; column++) {
      final x = column * columnStep + (column.isEven ? size(8) : size(18));
      final speed = 0.72 + (column % 5) * 0.18;
      final verticalShift = (phase * speed + column * 9) % rowStep;
      final columnHighlight = (phase + column * 7) % rows;

      for (var row = -1; row < rows; row++) {
        final y = row * rowStep + verticalShift;
        if (y < -rowStep || y > canvasSize.height + rowStep) continue;

        final distance = ((row - columnHighlight).abs() % rows).toDouble();
        final pulse = math.max(0.0, 1.0 - distance / 5.5);
        final edgeFade = _edgeFade(x, canvasSize.width);
        final baseAlpha =
            (isDark ? 0.035 : 0.075) +
            ((column + row).abs() % 4) * (isDark ? 0.014 : 0.022);
        final alpha = (baseAlpha + pulse * (isDark ? 0.12 : 0.22)) * edgeFade;
        if (alpha <= (isDark ? 0.006 : 0.018)) continue;

        final digit = ((column * 7 + row * 3 + phase.floor()) % 10).abs();
        final color = column.isEven ? cyan : green;
        textPainter.text = TextSpan(
          text: '$digit',
          style: TextStyle(
            color: color.withValues(alpha: alpha),
            fontSize: font((isDark ? 12 : 13) + pulse * (isDark ? 3 : 4)),
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

  void _drawCircuitTraces(Canvas canvas, Size canvasSize) {
    final cyanPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = cyan.withValues(alpha: isDark ? 0.18 : 0.34);
    final bluePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = blue.withValues(alpha: isDark ? 0.15 : 0.25);

    final topTrace = Path()
      ..moveTo(canvasSize.width * 0.04, canvasSize.height * 0.18)
      ..lineTo(canvasSize.width * 0.18, canvasSize.height * 0.18)
      ..lineTo(canvasSize.width * 0.23, canvasSize.height * 0.12)
      ..lineTo(canvasSize.width * 0.42, canvasSize.height * 0.12)
      ..lineTo(canvasSize.width * 0.48, canvasSize.height * 0.22)
      ..lineTo(canvasSize.width * 0.62, canvasSize.height * 0.22);
    canvas.drawPath(topTrace, cyanPaint);

    final middleTrace = Path()
      ..moveTo(canvasSize.width * 0.92, canvasSize.height * 0.28)
      ..lineTo(canvasSize.width * 0.74, canvasSize.height * 0.28)
      ..lineTo(canvasSize.width * 0.69, canvasSize.height * 0.38)
      ..lineTo(canvasSize.width * 0.56, canvasSize.height * 0.38)
      ..lineTo(canvasSize.width * 0.50, canvasSize.height * 0.48)
      ..lineTo(canvasSize.width * 0.34, canvasSize.height * 0.48);
    canvas.drawPath(middleTrace, bluePaint);

    final lowerTrace = Path()
      ..moveTo(canvasSize.width * 0.07, canvasSize.height * 0.72)
      ..lineTo(canvasSize.width * 0.18, canvasSize.height * 0.72)
      ..lineTo(canvasSize.width * 0.23, canvasSize.height * 0.64)
      ..lineTo(canvasSize.width * 0.37, canvasSize.height * 0.64)
      ..lineTo(canvasSize.width * 0.42, canvasSize.height * 0.76)
      ..lineTo(canvasSize.width * 0.57, canvasSize.height * 0.76)
      ..lineTo(canvasSize.width * 0.62, canvasSize.height * 0.68)
      ..lineTo(canvasSize.width * 0.82, canvasSize.height * 0.68);
    canvas.drawPath(lowerTrace, cyanPaint);

    final nodePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = cyan.withValues(alpha: isDark ? 0.44 : 0.72);
    final nodes = [
      Offset(canvasSize.width * 0.23, canvasSize.height * 0.12),
      Offset(canvasSize.width * 0.48, canvasSize.height * 0.22),
      Offset(canvasSize.width * 0.69, canvasSize.height * 0.38),
      Offset(canvasSize.width * 0.50, canvasSize.height * 0.48),
      Offset(canvasSize.width * 0.23, canvasSize.height * 0.64),
      Offset(canvasSize.width * 0.42, canvasSize.height * 0.76),
      Offset(canvasSize.width * 0.62, canvasSize.height * 0.68),
    ];
    for (final node in nodes) {
      canvas.drawCircle(node, 2.4, nodePaint);
      canvas.drawCircle(
        node,
        5.8,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7
          ..color = cyan.withValues(alpha: isDark ? 0.18 : 0.36),
      );
    }
  }

  void _drawCornerBrackets(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = cyan.withValues(alpha: isDark ? 0.24 : 0.42);
    final inset = size(20);
    final length = size(54);

    final paths = [
      Path()
        ..moveTo(inset, inset + length)
        ..lineTo(inset, inset)
        ..lineTo(inset + length, inset),
      Path()
        ..moveTo(canvasSize.width - inset - length, inset)
        ..lineTo(canvasSize.width - inset, inset)
        ..lineTo(canvasSize.width - inset, inset + length),
      Path()
        ..moveTo(inset, canvasSize.height - inset - length)
        ..lineTo(inset, canvasSize.height - inset)
        ..lineTo(inset + length, canvasSize.height - inset),
      Path()
        ..moveTo(canvasSize.width - inset - length, canvasSize.height - inset)
        ..lineTo(canvasSize.width - inset, canvasSize.height - inset)
        ..lineTo(canvasSize.width - inset, canvasSize.height - inset - length),
    ];

    for (final path in paths) {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashboardBackgroundPainter oldDelegate) =>
      oldDelegate.tick != tick ||
      oldDelegate.isDark != isDark ||
      oldDelegate.background != background ||
      oldDelegate.panelSoft != panelSoft ||
      oldDelegate.cyan != cyan ||
      oldDelegate.green != green ||
      oldDelegate.blue != blue ||
      oldDelegate.scale != scale;
}
