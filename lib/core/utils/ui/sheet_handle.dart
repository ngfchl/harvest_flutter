import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

Widget buildHandle(BuildContext context) => Center(
  child: Container(
    width: 36,
    height: 4,
    decoration: BoxDecoration(color: context.theme.colors.border, borderRadius: BorderRadius.circular(99)),
  ),
);
