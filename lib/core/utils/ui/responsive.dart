import 'package:flutter/material.dart';

const kMobileBreakpoint = 600.0;
const kDesktopBreakpoint = 1024.0;

extension ResponsiveContextExt on BuildContext {
  bool get isMobile => MediaQuery.sizeOf(this).width < kMobileBreakpoint;

  bool get isDesktop => MediaQuery.sizeOf(this).width >= kDesktopBreakpoint;
}
