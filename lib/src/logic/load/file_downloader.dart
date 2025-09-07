import 'dart:io' as io;
import 'dart:convert' as cv;

import 'package:path_provider/path_provider.dart';
import 'package:study_cards/src/logic/utils/platform_helper.dart';
import 'package:universal_html/html.dart';

/// Class to handle downloading files.
class FileDownloader {
  /// Saves the deck file on device based on the platform.
  static Future<bool> saveFileOnDevice(
      String fileName, String inFile, Map<String, String> mediaMap) async {
    try {
      switch (PlatformHelper.platform) {
        case PlatformType.web:
          final bytes = cv.utf8.encode(inFile);
          final blob = Blob([bytes]);
          final url = Url.createObjectUrlFromBlob(blob);
          AnchorElement(href: url)
            ..setAttribute("download", fileName)
            ..click();
          Url.revokeObjectUrl(url);
          return true;
        default:
          io.Directory directory;
          switch (PlatformHelper.platform) {
            case PlatformType.android:
              directory = io.Directory("/storage/emulated/0/Download");
              break;
            case PlatformType.ios:
              directory = await getApplicationDocumentsDirectory();
              break;
            default:
              var dir = await getDownloadsDirectory();
              if (dir == null) return false;
              directory = dir;
              break;
          }
          final path = '${directory.path}/$fileName';
          final file = io.File(path);
          await file.writeAsString(inFile, flush: true);
          return true;
      }
    } catch (e) {
      return false;
    }
  }
}
