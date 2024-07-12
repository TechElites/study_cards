import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

/// Class to handle donwloading files on mobile devices.
class FileDownloaderMobile {
  /// Save the deck file on mobile device.
  static Future<bool> saveFileOnDevice(
      String fileName, String inFile, Map<String, String> mediaMap) async {
    try {
      final directory = Platform.isAndroid
          ? Directory("/storage/emulated/0/Download")
          : await getApplicationDocumentsDirectory();
      if (mediaMap.isEmpty) {
        final path = '${directory.path}/$fileName';
        final file = File(path);
        await file.writeAsString(inFile, flush: true);
      } else {
        List bytes = [];
        for (var i = 0; i < mediaMap.length; i++) {
          bytes
              .add(await File(mediaMap.entries.elementAt(i).key).readAsBytes());
        }
        final tmpDir = await getTemporaryDirectory();
        final tmpPath = '${tmpDir.path}/$fileName';
        final file = File(tmpPath);
        final res = await file.writeAsString(inFile, flush: true);
        bytes.add(await res.readAsBytes());
        final archive = Archive();
        for (var i = 0; i < bytes.length; i++) {
          if (i == 0) {
            archive.addFile(ArchiveFile(fileName, bytes[i].length, bytes[i]));
          } else {
            archive.addFile(ArchiveFile(mediaMap.entries.elementAt(i - 1).value,
                bytes[i].length, bytes[i]));
          }
        }
        final zipEncoder = ZipEncoder();
        final encodedFile = zipEncoder.encode(archive);
        if (encodedFile != null) {
          await File('${directory.path}/${fileName.split('.xml')[0]}.zip')
              .writeAsBytes(encodedFile);
        } else {
          return false;
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
