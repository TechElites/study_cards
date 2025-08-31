import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;
import 'dart:convert' as cv;

import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart';

/// Class to handle downloading files.
class FileDownloader {
  /// Saves the deck file on device based on the platform.
  static Future<bool> saveFileOnDevice(
      String fileName, String inFile, Map<String, String> mediaMap) async {
    try {
      if (!kIsWeb) {
        final directory = io.Platform.isAndroid
            ? io.Directory("/storage/emulated/0/Download")
            : await getApplicationDocumentsDirectory();
        final path = '${directory.path}/$fileName';
        final file = io.File(path);
        await file.writeAsString(inFile, flush: true);
        return true;
      } else {
        final bytes = cv.utf8.encode(inFile);
        final blob = Blob([bytes]);
        final url = Url.createObjectUrlFromBlob(blob);
        AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..click();
        Url.revokeObjectUrl(url);
        return true;
      }
    } catch (e) {
      return false;
    }
  }
}
