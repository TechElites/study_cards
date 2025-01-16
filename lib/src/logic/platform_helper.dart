import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformHelper {
  static const String mobile = 'mobile';
  static const String web = 'web';
  static const String desktop = 'desktop';

  static bool get isMobile {
    return Platform.isAndroid || Platform.isIOS;
  }

  static bool get isWeb {
    return kIsWeb;
  }

  static bool get isDesktop {
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  static String get platform {
    if (isMobile) {
      return mobile;
    } else if (isWeb) {
      return web;
    } else if (isDesktop) {
      return desktop;
    }
    return '';
  }
}