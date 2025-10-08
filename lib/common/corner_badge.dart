import 'package:flutter/material.dart';

class CornerBadge extends StatelessWidget {
  final Widget child;
  final String label;
  final Color color;
  final double angle; // 旋转角度（弧度），正值顺时针，负值逆时针
  final double offsetX; // 往外水平偏移（正值表示往右外）
  final double offsetY; // 往外垂直偏移（正值表示往上外）
  final bool triangular; // 是否三角形角标
  final double size; // 正方形区域大小（绘制三角）
  final double fontSize;

  /// 文本放置在三角形内的相对位置（以正方形左上角为原点）
  /// x,y 为相对比例，范围 0..1。默认约置于斜边附近（可微调）。
  final Offset textOffsetFraction;

  const CornerBadge({
    super.key,
    required this.child,
    required this.label,
    this.color = Colors.red,
    this.angle = 0,
    this.offsetX = 6,
    this.offsetY = 6,
    this.triangular = false,
    this.size = 48,
    this.fontSize = 10,
    this.textOffsetFraction = const Offset(0.22, 0.22),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        // 固定右上角，使用 offsetX/offsetY 可精确控制外偏移
        Positioned(
          top: -offsetY,
          right: -offsetX,
          child: triangular ? _buildTriangleBadge() : _buildRectBadge(),
        ),
      ],
    );
  }

  /// 普通矩形倾斜角标（整个矩形连同文字一起旋转）
  Widget _buildRectBadge() {
    return Transform.rotate(
      angle: angle,
      alignment: Alignment.topRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        child: Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// 三角角标（整体旋转，文字随三角倾斜）
  Widget _buildTriangleBadge() {
    final s = size;

    return SizedBox(
      width: s,
      height: s,
      child: Transform.rotate(
        angle: angle,
        alignment: Alignment.topRight,
        child: CustomPaint(
          size: Size(s, s),
          painter: _TriangleWithTextPainter(
            color: color,
            text: label,
            fontSize: fontSize,
            textOffsetFraction: textOffsetFraction,
          ),
        ),
      ),
    );
  }
}

class _TriangleWithTextPainter extends CustomPainter {
  final Color color;
  final String text;
  final double fontSize;
  final Offset textOffsetFraction;

  _TriangleWithTextPainter({
    required this.color,
    required this.text,
    required this.fontSize,
    required this.textOffsetFraction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 画三角
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(path, paint);

    // 画文字（文字随三角旋转）
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    );
    textPainter.layout(maxWidth: size.width * 0.6);

    final dx = size.width * textOffsetFraction.dx;
    final dy = size.height * textOffsetFraction.dy;

    // 平移到指定位置
    canvas.save();
    canvas.translate(dx, dy);
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TriangleWithTextPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.text != text;
}
