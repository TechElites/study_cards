import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flash_cards/src/data/model/card/study_card.dart';
import 'package:flash_cards/src/logic/json_handler.dart';
import 'package:flash_cards/src/logic/xml_handler.dart';
import 'package:flash_cards/src/logic/permission_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Class to handle uploading files on mobile devices.
class FileUploaderMobile {
  /// Reads a deck file on mobile devices.
  static Future<List<StudyCard>> uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xml', 'zip', 'json'],
    );

    if (result != null && result.files.isNotEmpty) {
      File file = File(result.files.single.path!);
      String fileContent = '';
      String fileExtension = file.path.endsWith('.json') ? 'json' : 'xml';
      if (file.path.endsWith('.zip')) {
        fileContent = await _unzipFile(file).then((value) {
          fileExtension = value!.path.endsWith('.json') ? 'json' : 'xml';
          return value.readAsString();
        });
      } else {
        fileContent = await file.readAsString();
      }
      return fileExtension == 'json'
          ? await JsonHandler().parseJson(fileContent)
          : await XmlHandler.parseXml(fileContent);
    }

    return [];
  }

  /// Unzips the file and returns the xml file.
  static Future<File?> _unzipFile(File zipFile) async {
    try {
      Directory? externalDir;
      if (Platform.isAndroid) {
        final hasPermission =
            await PermissionHelper.requestStoragePermissions();
        if (!hasPermission) {
          throw Exception("Missing storage permissions.");
        }
        externalDir = await getExternalStorageDirectory();
      } else {
        externalDir = await getApplicationDocumentsDirectory();
      }
      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      String zipFileName = path.basenameWithoutExtension(zipFile.path);
      Directory destinationDir =
          Directory(path.join(externalDir!.path, zipFileName));
      await destinationDir.create(recursive: true);

      File? xmlFile;
      for (final file in archive) {
        if (file.isFile) {
          final filename = file.name;
          final filePath = path.join(destinationDir.path, filename);

          final outputFile = File(filePath);
          await outputFile.create(recursive: true);
          await outputFile.writeAsBytes(file.content as List<int>);

          if (path.extension(filename) == '.xml') {
            xmlFile = outputFile;
          }
        } else {
          final dirPath = path.join(destinationDir.path, file.name);
          await Directory(dirPath).create(recursive: true);
        }
      }

      return xmlFile;
    } catch (e) {
      throw Exception('Error while unzipping $e');
    }
  }
}
