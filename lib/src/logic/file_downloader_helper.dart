import 'dart:developer';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';

class FileDownloaderHelper {
  static Future<void> saveFileOnDevice(String fileName, String inFile) async {
    try {
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
        log("=> saved file: ${res.path}");
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