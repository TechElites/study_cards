import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flash_cards/src/logic/downloader/file_downloader_mobile.dart';
import 'package:flash_cards/src/logic/downloader/file_downloader_web.dart';

/// Class to handle downloading files.
class FileDownloader {
  /// Saves the deck file on device based on the platform.
  static Future<void> saveFileOnDevice(
      String fileName, String inFile, Map<String, String> mediaMap) async {
    try {
      if (kIsWeb) {
        FileDownloaderWeb.saveFileOnDevice(fileName, inFile);
      } else {
        FileDownloaderMobile.saveFileOnDevice(fileName, inFile, mediaMap);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
