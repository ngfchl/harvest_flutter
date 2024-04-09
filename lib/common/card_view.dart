import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry? padding;
  final Color color;
  final BorderRadiusGeometry borderRadius;
  final List<BoxShadow> boxShadow;

  const CustomCard({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.padding = const EdgeInsets.all(4),
    this.color = Colors.white,
    this.borderRadius = const BorderRadius.only(
      topLeft: Radius.circular(8.0),
      bottomLeft: Radius.circular(8.0),
      bottomRight: Radius.circular(8.0),
      topRight: Radius.circular(8.0),
    ),
    this.boxShadow = const [
      BoxShadow(
        color: Colors.grey,
        offset: Offset(1.1, 1.1),
        blurRadius: 10.0,
      ),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}
