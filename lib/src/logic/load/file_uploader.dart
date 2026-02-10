import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:study_cards/src/data/model/card/study_card.dart';
import 'package:study_cards/src/logic/load/extension_handler.dart';
import 'package:study_cards/src/logic/permission_helper.dart';
import 'package:study_cards/src/logic/utils/platform_helper.dart';

/// Class to handle uploading files.
class FileUploader {
  /// Reads a deck file based on the platform.
  static Future<List<StudyCard>> uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xml', 'json', 'zip'],
    );

    if (result != null) {
      if (PlatformHelper.isWeb) {
        final file = result.files.first;
        final fileContent = utf8.decode(file.bytes!);
        return fileContent.startsWith('{')
            ? await ExtensionHandler.parseJson(fileContent)
            : await ExtensionHandler.parseXml(fileContent);
      } else {
        if (result.files.isNotEmpty) {
          File file = File(result.files.single.path!);
          if (file.path.endsWith('.zip')) {
            return await _loadLegacyZipDeck(file);
          }
          String fileContent = await file.readAsString();
          return fileContent.startsWith('{')
              ? await ExtensionHandler.parseJson(fileContent)
              : await ExtensionHandler.parseXml(fileContent);
        }
      }
    }

    return [];
  }

  /// Loads a legacy deck from a ZIP file with images
  static Future<List<StudyCard>> _loadLegacyZipDeck(File zipFile) async {
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
          Directory(path.join(externalDir!.path, 'temp_legacy', zipFileName));
      await destinationDir.create(recursive: true);
      Map<String, File> imageFiles = {};
      File? jsonOrXmlFile;
      for (final file in archive) {
        if (file.isFile) {
          final filename = file.name;
          final filePath = path.join(destinationDir.path, filename);
          final outputFile = File(filePath);
          await outputFile.create(recursive: true);
          await outputFile.writeAsBytes(file.content as List<int>);
          if (path.extension(filename) == '.json' ||
              path.extension(filename) == '.xml') {
            jsonOrXmlFile = outputFile;
          } else if (path.extension(filename) == '.png' ||
              path.extension(filename) == '.jpg' ||
              path.extension(filename) == '.jpeg') {
            imageFiles[filename] = outputFile;
          }
        } else {
          final dirPath = path.join(destinationDir.path, file.name);
          await Directory(dirPath).create(recursive: true);
        }
      }
      if (jsonOrXmlFile == null) {
        throw Exception('No JSON or XML file found in ZIP');
      }
      String fileContent = await jsonOrXmlFile.readAsString();
      List<StudyCard> cards;
      if (fileContent.startsWith('{')) {
        cards = await ExtensionHandler.parseLegacyJson(
            fileContent, destinationDir.path, imageFiles);
      } else {
        cards = await ExtensionHandler.parseLegacyXml(
            fileContent, destinationDir.path, imageFiles);
      }
      try {
        await destinationDir.delete(recursive: true);
      } catch (e) {
        throw Exception('Error cleaning up temporary files: $e');
      }
      return cards;
    } catch (e) {
      throw Exception('Error loading legacy ZIP deck: $e');
    }
  }
}
