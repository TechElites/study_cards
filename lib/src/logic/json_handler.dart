import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flash_cards/src/data/model/card/study_card.dart';
import 'package:flash_cards/src/logic/downloader/file_downloader.dart';
import 'package:flutter_launcher_icons/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class JsonHandler {
  /// Parse the json string and return a list of StudyCard objects
  Future<List<StudyCard>> parseJson(String jsonString) async {
    final jsonData = jsonDecode(jsonString);
    final deckName = jsonData['deckName'];
    //print(jsonData);
    List<StudyCard> parsedData = [];
    parsedData
        .add(StudyCard(front: deckName, back: jsonData['length'].toString()));
    var appPath = '';
    final Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    appPath = directory!.path;
    for (var card in jsonData['cards']) {
      //print("front media: " + card['front_media'][0]);
      parsedData.add(StudyCard(
          front: card['front_text'],
          back: card['back_text'],
          frontMedia: card['front_media'].isNotEmpty
              ? path.join(appPath.toString(), deckName, card['frontMedia'][0])
              : '',
          backMedia: card['back_media'].isNotEmpty
              ? path.join(appPath.toString(), deckName, card['frontMedia'][0])
              : ''));

      /*var appPath = '';
      final Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      appPath = directory!.path;
      card.frontMedia = card['frontMedia'][0] != null
          ? path.join(appPath.toString(), deckName, card['frontMedia'][0])
          : '';
      card.backMedia = card['backtMedia'][0] != null
          ? path.join(appPath.toString(), deckName, card['frontMedia'][0])
          : '';
    */
    }
    return parsedData;
  }

  // convert a list of StudyCard objects to a json string
  static String convertToJson(List<StudyCard> cards) {
    List<Map<String, dynamic>> jsonData = [];
    jsonData.add({'deckName': cards[0].front});
    jsonData.add({'length': cards.length});
    for (var card in cards) {
      jsonData.add({
        'front': card.front,
        'back': card.back,
        'frontMedia': card.frontMedia,
        'backMedia': card.backMedia
      });
    }
    return prettifyJsonEncode(jsonData);
  }

  /// Saves the XML string to a file.
  static Future<bool> saveJSONToFile(
      String jsonString, String fileName, Map<String, String> mediaMap) async {
    return FileDownloader.saveFileOnDevice(fileName, jsonString, mediaMap);
  }
}
