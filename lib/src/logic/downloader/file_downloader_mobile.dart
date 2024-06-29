import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

class FileDownloaderMobile {
  static Future<void> saveFileOnDevice(
      String fileName, String inFile, Map<String, String> mediaMap) async {
    List bytes = [];
    switch (Platform.operatingSystem) {
      case 'android':
        final directory = Directory("/storage/emulated/0/Download");
        if (!directory.existsSync()) {
          await directory.create();
        }
        final path = '${directory.path}/$fileName';
        final outFile = File(path);
        final res = await outFile.writeAsString(inFile, flush: true);
        bytes.add(await res.readAsBytes());
        if (mediaMap.isNotEmpty) {
          for (var i = 0; i < mediaMap.length; i++) {
            bytes.add(
                await File(mediaMap.entries.elementAt(i).key).readAsBytes());
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
            await File('${directory.path}/${fileName.split('.xml')[0]}.zip')
                .writeAsBytes(encodedFile);
          }
          await outFile.delete();
        }
        break;
      case 'ios':
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/$fileName';
        final file = File(path);
        await file.writeAsString(inFile);
        await Share.shareXFiles([XFile(path)]);
        break;
      default:
        break;
    }
  }
}
