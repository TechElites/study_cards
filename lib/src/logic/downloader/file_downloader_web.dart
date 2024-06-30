import 'package:universal_html/html.dart';
import 'dart:convert';

/// Class to handle downloading files on web.
class FileDownloaderWeb {
  /// Save the deck file on web.
  static Future<void> saveFileOnDevice(String fileName, String inFile) async {
    try {
      final bytes = utf8.encode(inFile);
      final blob = Blob([bytes]);
      final url = Url.createObjectUrlFromBlob(blob);
      AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..click();
      Url.revokeObjectUrl(url);
    } catch (e) {
      throw Exception(e);
    }
  }
}
