import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;
import 'dart:convert' as cv;

import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
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
        final res = await file.writeAsString(inFile, flush: true);
        if (mediaMap.isNotEmpty) {
          List bytes = [];
          bytes.add(await res.readAsBytes());
          for (var i = 0; i < mediaMap.length; i++) {
            bytes.add(
                await io.File(mediaMap.entries.elementAt(i).key).readAsBytes());
          }
          final archive = Archive();
          for (var i = 0; i < bytes.length; i++) {
            if (i == 0) {
              archive.addFile(ArchiveFile(fileName, bytes[i].length, bytes[i]));
            } else {
              archive.addFile(ArchiveFile(
                  mediaMap.entries.elementAt(i - 1).value,
                  bytes[i].length,
                  bytes[i]));
            }
          }
          final zipEncoder = ZipEncoder();
          final encodedFile = zipEncoder.encode(archive);
          if (encodedFile != null) {
            final String extension = fileName.split('.').last;
            await io.File('${directory.path}/${fileName.split(extension)[0]}zip')
                .writeAsBytes(encodedFile);
          } else {
            return false;
          }
        }
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
