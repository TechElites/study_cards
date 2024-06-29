import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flash_cards/src/data/model/card/study_card.dart';
import 'package:flash_cards/src/logic/xml_handler.dart';

class FileUploaderWeb {
  static Future<List<StudyCard>> uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xml'],
    );
    if (result != null) {
      final file = result.files.first;
      final fileContent = utf8.decode(file.bytes!);
      return await XmlHandler.parseSimpleXml(fileContent);
    }
    return [];
  }
}
