import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

Widget buildHandle(BuildContext context) => Center(
  child: Container(
    width: 36,
    height: 4,
    decoration: BoxDecoration(
      color: shadcn.Theme.of(context).colorScheme.border,
      borderRadius: BorderRadius.circular(99),
    ),
  ),
);
