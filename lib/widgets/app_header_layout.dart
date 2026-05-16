import 'package:flutter/widgets.dart';
import 'package:harvest/core/utils/utils.dart';

const double kAppHeaderHeight = 52;
const double kMacosWindowControlInset = 63;

double appHeaderLeadingInset(BuildContext context) {
  if (PlatformTool.isMacOS() && !context.isMobile) {
    return kMacosWindowControlInset;
  }
  return 0;
}

double appHeaderTrailingInset(BuildContext context) {
  return 0;
}

EdgeInsets appHeaderPadding(
  BuildContext context, {
  double left = 0,
  double top = 6,
  double right = 8,
  double bottom = 6,
}) {
  return EdgeInsets.fromLTRB(
    left + appHeaderLeadingInset(context),
    top,
    right + appHeaderTrailingInset(context),
    bottom,
  );
}
