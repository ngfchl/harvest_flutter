import 'package:flutter/material.dart';

import '../../shell/widgets/shell_scaffold.dart';

double newsBottomPadding(BuildContext context) {
  final media = MediaQuery.of(context);
  final safeBottom = media.padding.bottom > 0 ? media.padding.bottom : media.viewPadding.bottom;
  return 32 + ShellBottomSpacing.value(context) + safeBottom;
}
