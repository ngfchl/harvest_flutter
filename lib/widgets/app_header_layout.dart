import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/shell/widgets/global_drawer_swipe_area.dart';

const double kAppHeaderHeight = 52;
const double kDesktopWindowControlsInset = 14;
const double kDesktopWindowControlsReservedWidth = 102;
const double kDesktopWindowControlsLeadingReservedWidth = 90;

double appHeaderLeadingInset(BuildContext context) {
  if (!PlatformTool.isWeb() &&
      (PlatformTool.isMacOS() || PlatformTool.isLinux()) &&
      !context.isMobile) {
    final sidebarVisible = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(desktopNavigationSidebarVisibleProvider);
    final sidebarActuallyVisible = context.isDesktop && sidebarVisible;
    return sidebarActuallyVisible
        ? 0
        : kDesktopWindowControlsLeadingReservedWidth;
  }
  return 0;
}

double appHeaderStandaloneLeadingInset(BuildContext context) {
  if (!PlatformTool.isWeb() &&
      (PlatformTool.isMacOS() || PlatformTool.isLinux()) &&
      !context.isMobile) {
    return kDesktopWindowControlsLeadingReservedWidth;
  }
  return 0;
}

double appHeaderTrailingInset(BuildContext context) {
  if (!PlatformTool.isWeb() && PlatformTool.isWindows() && !context.isMobile) {
    return kDesktopWindowControlsReservedWidth;
  }
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

EdgeInsets appStandaloneHeaderPadding(
  BuildContext context, {
  double left = 0,
  double top = 6,
  double right = 8,
  double bottom = 6,
}) {
  return EdgeInsets.fromLTRB(
    left + appHeaderStandaloneLeadingInset(context),
    top,
    right + appHeaderTrailingInset(context),
    bottom,
  );
}
