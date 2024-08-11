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

  static bool isPhone() {
    final data = MediaQueryData.fromView(
        WidgetsBinding.instance.platformDispatcher.views.first);
    return data.size.shortestSide < 600 ||
        (!kIsWeb && (Platform.isAndroid || Platform.isIOS));
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
