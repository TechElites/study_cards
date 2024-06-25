import 'dart:developer';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

class FileDownloaderHelper {
  static Future<void> saveFileOnDevice(
      String fileName, String inFile, Map<String, String> MediaMap) async {
    try {
      List bytes = [];
      if (Platform.isAndroid) {
        // Check if the platform is Android
        final directory = Directory("/storage/emulated/0/Download");

        if (!directory.existsSync()) {
          // Create the directory if it doesn't exist
          await directory.create();
        }
        final path = '${directory.path}/$fileName';
        final outFile = File(path);

        final res = await outFile.writeAsString(inFile, flush: true);
        bytes.add(await res.readAsBytes());
        log("=> saved file: ${res.path}");
        if (MediaMap.isNotEmpty) {
          for (var i = 0; i < MediaMap.length; i++) {
            bytes.add(
                await File(MediaMap.entries.elementAt(i).key).readAsBytes());
            //bytes.add(await File(MediaList[i]).readAsBytes());
          }
        }
        //List archiveList = [];
        final archive = Archive();
        for (var i = 0; i < bytes.length; i++) {
          if (i == 0) {
            archive.addFile(ArchiveFile(fileName, bytes[i].length, bytes[i]));
          } else {
            archive.addFile(ArchiveFile(MediaMap.entries.elementAt(i - 1).value,
                bytes[i].length, bytes[i]));
          }
        }
        final zipEncoder = ZipEncoder();
        final encodedFile = zipEncoder.encode(archive);
        if (encodedFile != null) {
          // Save the zip file to the device
          await File('${directory.path}/${fileName.split('.xml')[0]}.zip')
              .writeAsBytes(encodedFile);
        }
        //final zipFile = await File('${directory.path}/$fileName.zip').writeAsBytes(encodedFile);
      } else {
        // IOS
        final directory = await getApplicationDocumentsDirectory();
        // Get the application documents directory path
        final path = '${directory.path}/$fileName';
        final file = File(path);
        await file.writeAsString(inFile);
        // final res = await Share.shareXFiles([XFile(path)]);
        // log("=> saved status: ${res.status}");
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
