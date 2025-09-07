import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Enum representing different platform types
enum PlatformType { android, ios, web, windows, macos, linux, fuchsia, unknown }

/// Helper class to determine the platform
class PlatformHelper {

  static PlatformType get platform {
    if (kIsWeb) {
      return PlatformType.web;
    } else if (io.Platform.isAndroid) {
      return PlatformType.android;
    } else if (io.Platform.isIOS) {
      return PlatformType.ios;
    } else if (io.Platform.isWindows) {
      return PlatformType.windows;
    } else if (io.Platform.isMacOS) {
      return PlatformType.macos;
    } else if (io.Platform.isLinux) {
      return PlatformType.linux;
    } else if (io.Platform.isFuchsia) {
      return PlatformType.fuchsia;
    } else {
      return PlatformType.unknown;
    }
  }

  static bool get isAndroid => io.Platform.isAndroid;
  static bool get isIOS => io.Platform.isIOS;
  static bool get isMobile => io.Platform.isAndroid || io.Platform.isIOS;
  static bool get isDesktop => io.Platform.isWindows || io.Platform.isMacOS || io.Platform.isLinux;
  static bool get isWeb => kIsWeb;
}