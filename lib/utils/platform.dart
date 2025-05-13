import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlatformTool {
  static bool isIOS() {
    try {
      return Platform.isIOS;
    } catch (e) {
      return false;
    }
  }

  static bool isAndroid() {
    try {
      return Platform.isAndroid;
    } catch (e) {
      return false;
    }
  }

  static bool isWeb() {
    return kIsWeb;
  }

  static bool isMacOS() {
    try {
      return Platform.isMacOS;
    } catch (e) {
      return false;
    }
  }

  static bool isWindows() {
    try {
      return Platform.isWindows;
    } catch (e) {
      return false;
    }
  }

  static bool isLinux() {
    try {
      return Platform.isLinux || Platform.isFuchsia;
    } catch (e) {
      return false;
    }
  }

  /// 是否是手机（根据屏幕尺寸和平台判断）
  static bool isPhone() {
    final data = MediaQueryData.fromView(
      WidgetsBinding.instance.platformDispatcher.views.first,
    );

    final isSmallScreen = data.size.shortestSide < 600;

    if (kIsWeb) {
      // Web 上只能通过尺寸推断
      return isSmallScreen;
    } else {
      // 非 Web 平台，结合平台判断
      return (Platform.isAndroid || Platform.isIOS) && isSmallScreen;
    }
  }

  //** 是否竖屏 **//
  static bool isPortrait() {
    final size = MediaQueryData.fromView(
      WidgetsBinding.instance.platformDispatcher.views.first,
    ).size;
    return size.width < size.height && size.shortestSide < 600;
  }

  static bool isSmallScreen() {
    final size = MediaQueryData.fromView(
      WidgetsBinding.instance.platformDispatcher.views.first,
    ).size;

    return size.shortestSide < 600;
  }

  static bool isSmallScreenPortrait() {
    final size = MediaQueryData.fromView(
      WidgetsBinding.instance.platformDispatcher.views.first,
    ).size;

    return size.shortestSide < 600;
  }

  static bool isDesktopOS() {
    return isWindows() || isMacOS() || isLinux();
  }

  ///@title 判断是否是横屏
  ///@description
  ///@updateTime
  static bool isLandscape() {
    final data = MediaQueryData.fromView(
      WidgetsBinding.instance.platformDispatcher.views.first,
    );
    return data.orientation == Orientation.landscape;
  }

  static String operatingSystem() {
    try {
      return Platform.operatingSystem;
    } catch (e) {
      return 'unknown';
    }
  }

  static String operatingSystemVersion() {
    try {
      return Platform.operatingSystemVersion;
    } catch (e) {
      return 'unknown';
    }
  }

  static String localeName() {
    try {
      return Platform.localeName;
    } catch (e) {
      return 'zh_Hans_CN';
    }
  }
}
