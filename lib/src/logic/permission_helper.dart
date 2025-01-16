import 'dart:io';

import 'package:flash_cards/src/logic/platform_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Helper class to handle permissions.
class PermissionHelper {
  /// gets the according storage directory.
  static Future<Directory?> getStorageDirectory() async {
    Directory? externalDir;
    switch (PlatformHelper.platform) {
      case PlatformHelper.mobile:
        if (Platform.isAndroid) {
          var status = await Permission.storage.status;
          if (!status.isGranted) {
            status = await Permission.manageExternalStorage.request();
          }
          if (status == PermissionStatus.denied) {
            throw Exception("Missing storage permissions.");
          }
          externalDir = await getExternalStorageDirectory();
        } else {
          externalDir = await getApplicationDocumentsDirectory();
        }
      case PlatformHelper.desktop:
        externalDir = await getApplicationSupportDirectory();
    }
    return externalDir;
  }
}
