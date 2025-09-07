import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:study_cards/src/data/model/card/study_card.dart';
import 'package:study_cards/src/logic/load/extension_handler.dart';
import 'package:study_cards/src/logic/utils/platform_helper.dart';

/// Class to handle uploading files.
class FileUploader {
  /// Reads a deck file based on the platform.
  static Future<List<StudyCard>> uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xml', 'json'],
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
          String fileContent = await file.readAsString();
          return fileContent.startsWith('{')
              ? await ExtensionHandler.parseJson(fileContent)
              : await ExtensionHandler.parseXml(fileContent);
        }
      }
    }

    return [];
  }
}
