import 'dart:developer';

import 'package:permission_handler/permission_handler.dart';

/// Helper class to handle permissions.
class PermissionHelper {
  /// Requests storage permissions.
  static Future<bool> requestStoragePermissions() async {
    var status = await Permission.storage.status;
    log("=> storage permission satus: $status");
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    return status == PermissionStatus.granted;
  }
}