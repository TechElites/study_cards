import 'package:flash_cards/src/data/model/card/study_card.dart';
import 'package:flash_cards/src/logic/uploader/file_uploader_mobile.dart';
import 'package:flash_cards/src/logic/uploader/file_uploader_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FileUploader {
  static Future<List<StudyCard>> uploadFile() async {
    if (kIsWeb) {
      return await FileUploaderWeb.uploadFile();
    } else {
      return await FileUploaderMobile.uploadFile();
    }
  }
}
