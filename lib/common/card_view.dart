import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../app/home/pages/models/color_storage.dart';
import '../utils/storage.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final BorderRadius borderRadius;
  final double? height;
  final double? maxHeight;
  final double? width;

  const CustomCard({
    super.key,
    required this.child,
    this.color,
    this.maxHeight,
    this.borderRadius = const BorderRadius.only(
      topLeft: Radius.circular(8.0),
      bottomLeft: Radius.circular(8.0),
      bottomRight: Radius.circular(8.0),
      topRight: Radius.circular(8.0),
    ),
    this.height,
    this.width,
    this.padding = const EdgeInsets.all(4.0),
    this.margin = const EdgeInsets.all(4.0),
  });

  @override
  Widget build(BuildContext context) {
    double opacity = SPUtil.getDouble('cardOpacity', defaultValue: 0.7);
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    SiteColorConfig siteColorConfig = SiteColorConfig.load(shadColorScheme);
    return Container(
      margin: margin,
      child: ShadCard(
        height: height,
        width: width,
        padding: padding,
        radius: borderRadius,
        backgroundColor: color ?? siteColorConfig.siteCardColor.value.withOpacity(opacity),
        child: child,
      ),
    );
  }
}

class CurvePainter extends CustomPainter {
  final double? angle;
  final List<Color>? colors;

  CurvePainter({this.colors, this.angle = 140});

  @override
  void paint(Canvas canvas, Size size) {
    List<Color> colorsList = [];
    if (colors != null) {
      colorsList = colors ?? [];
    } else {
      colorsList.addAll([Colors.white, Colors.white]);
    }

    final shdowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    final shdowPaintCenter = Offset(size.width / 2, size.height / 2);
    final shdowPaintRadius = math.min(size.width / 2, size.height / 2) - (14 / 2);
    canvas.drawArc(Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius), degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)), false, shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.3);
    shdowPaint.strokeWidth = 16;
    canvas.drawArc(Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius), degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)), false, shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.2);
    shdowPaint.strokeWidth = 20;
    canvas.drawArc(Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius), degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)), false, shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.1);
    shdowPaint.strokeWidth = 22;
    canvas.drawArc(Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius), degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)), false, shdowPaint);

    final rect = Rect.fromLTWH(0.0, 0.0, size.width, size.width);
    final gradient = SweepGradient(
      startAngle: degreeToRadians(268),
      endAngle: degreeToRadians(270.0 + 360),
      tileMode: TileMode.repeated,
      colors: colorsList,
    );
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.round // StrokeCap.round is not recommended.
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - (14 / 2);

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)), false, paint);

    const gradient1 = SweepGradient(
      tileMode: TileMode.repeated,
      colors: [Colors.white, Colors.white],
    );

    var cPaint = Paint();
    cPaint.shader = gradient1.createShader(rect);
    cPaint.color = Colors.white;
    cPaint.strokeWidth = 14 / 2;
    canvas.save();

    final centerToCircle = size.width / 2;
    canvas.save();

    canvas.translate(centerToCircle, centerToCircle);
    canvas.rotate(degreeToRadians(angle! + 2));

    canvas.save();
    canvas.translate(0.0, -centerToCircle + 14 / 2);
    canvas.drawCircle(const Offset(0, 0), 14 / 5, cPaint);

    canvas.restore();
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  double degreeToRadians(double degree) {
    var redian = (math.pi / 180) * degree;
    return redian;
  }
}

class CustomTextTag extends StatelessWidget {
  final String labelText;
  final double fontSize;
  final Color? labelColor;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final Icon? icon;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const CustomTextTag({
    super.key,
    required this.labelText,
    this.labelColor = Colors.white,
    this.backgroundColor = Colors.green,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
    this.icon,
    this.fontSize = 10,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          icon ?? const SizedBox.shrink(),
          if (icon != null) const SizedBox(width: 2),
          Text(
            labelText,
            style: TextStyle(fontSize: fontSize, color: labelColor),
          ),
        ],
      ),
    );
  }
}

class FilterItem extends StatelessWidget {
  final String name;
  final List<String> value;
  final List<String> selected;
  final Function() onUpdate;

  const FilterItem({
    super.key,
    required this.name,
    required this.value,
    required this.selected,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    var shadColorScheme = ShadTheme.of(context).colorScheme;

    return CustomCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          SizedBox(
            height: 30,
            child: ListTile(
              // contentPadding: const EdgeInsets.all(0),
              title: Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  color: shadColorScheme.foreground,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              children: value.map(
                (e) {
                  return FilterChip(
                    label: Text(
                      e.toString().isNotEmpty ? e.toString() : "无",
                      style: TextStyle(
                        color: shadColorScheme.primaryForeground,
                      ),
                    ),
                    selected: selected.contains(e.toString()),
                    backgroundColor: shadColorScheme.primary,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: shadColorScheme.primaryForeground,
                    ),
                    selectedColor: Colors.green,
                    pressElevation: 5,
                    elevation: 3,
                    onSelected: (value) {
                      if (value) {
                        selected.add(e.toString());
                      } else {
                        selected.removeWhere((item) => item == e.toString());
                      }
                      onUpdate();
                    },
                  );
                },
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
