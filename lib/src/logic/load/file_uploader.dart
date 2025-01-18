import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flash_cards/src/data/model/card/study_card.dart';
import 'package:flash_cards/src/logic/load/extension_handler.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:flash_cards/src/logic/permission_helper.dart';
import 'package:flash_cards/src/logic/platform_helper.dart';
import 'package:path/path.dart' as path;

/// Class to handle uploading files.
class FileUploader {
  /// Reads a deck file based on the platform.
  static Future<List<StudyCard>> uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xml', 'zip', 'json'],
    );

    if (result != null) {
      switch (PlatformHelper.platform) {
        case PlatformHelper.web:
          final file = result.files.first;
          final fileContent = utf8.decode(file.bytes!);
          return fileContent.startsWith('{')
                ? await ExtensionHandler.parseJson(fileContent)
                : await ExtensionHandler.parseSimpleXml(fileContent);
        default:
          if (result.files.isNotEmpty) {
            File file = File(result.files.single.path!);
            String fileContent = '';
            if (file.path.endsWith('.zip')) {
              fileContent =
                  await _unzipFile(file).then((value) => value!.readAsString());
            } else {
              fileContent = await file.readAsString();
            }
            return fileContent.startsWith('{')
                ? await ExtensionHandler.parseJson(fileContent)
                : await ExtensionHandler.parseSimpleXml(fileContent);
          }
          break;
      }
    }
    return [];
  }

  /// Unzips the file and returns the xml or json file.
  static Future<File?> _unzipFile(File zipFile) async {
    try {
      Directory? externalDir = await PermissionHelper.getStorageDirectory();
      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      String zipFileName = path.basenameWithoutExtension(zipFile.path);
      Directory destinationDir =
          Directory(path.join(externalDir!.path, zipFileName));
      await destinationDir.create(recursive: true);

      File? retFile;
      for (final file in archive) {
        if (file.isFile) {
          final filename = file.name;
          final filePath = path.join(destinationDir.path, filename);

          final outputFile = File(filePath);
          await outputFile.create(recursive: true);
          await outputFile.writeAsBytes(file.content as List<int>);

          if (path.extension(filename) == '.xml' ||
              path.extension(filename) == '.json') {
            await outputFile
                .writeAsString(utf8.decode(file.content as List<int>));
            retFile = outputFile;
          }
        } else {
          final dirPath = path.join(destinationDir.path, file.name);
          await Directory(dirPath).create(recursive: true);
        }
      }

      return retFile;
    } catch (e) {
      throw Exception('Error while unzipping $e');
    }
  }
}
