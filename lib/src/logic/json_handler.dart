import 'dart:convert';
import 'dart:io';

import 'package:flash_cards/src/data/model/card/study_card.dart';
import 'package:flash_cards/src/logic/downloader/file_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class JsonHandler {
  // parse the json string and return a list of StudyCard objects
  Future<List<StudyCard>> parseJson(String jsonString) async {
    final deckName = 'deckName';
    final jsonData = jsonDecode(jsonString);
    List<StudyCard> parsedData = [];
    parsedData.add(StudyCard(front: deckName, back: jsonData.length.toString()));
    for (var card in jsonData) {
      parsedData.add(StudyCard(
          front: card['front'],
          back: card['back'],
          // frontMedia and backMedia are arrays of strings
          frontMedia: card['frontMedia'],
          backMedia: card['backMedia']));
    
    var appPath = '';
      final Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      appPath = directory!.path;
      card.frontMedia = card.frontMedia != null
          ? path.join(appPath.toString(), deckName, card.frontMedia)
          : '';
      card.backMedia = card.backMedia != null
          ? path.join(appPath.toString(), deckName, card.backMedia)
          : '';
    }
    return parsedData;
  }

  // convert a list of StudyCard objects to a json string
  String convertToJson(List<StudyCard> cards) {
    List<Map<String, dynamic>> jsonData = [];
    for (var card in cards) {
      jsonData.add({
        'front': card.front,
        'back': card.back,
        'frontMedia': card.frontMedia,
        'backMedia': card.backMedia
      });
    }
    return jsonEncode(jsonData);
  }

/// Saves the XML string to a file.
  static Future<bool> saveJSONToFile(
      String jsonString, String fileName, Map<String, String> mediaMap) async {
    return FileDownloader.saveFileOnDevice(fileName, jsonString, mediaMap);
  }
}