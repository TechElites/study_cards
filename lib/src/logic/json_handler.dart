import 'dart:convert';
import 'dart:io';

import 'package:study_cards/src/data/model/card/study_card.dart';
import 'package:study_cards/src/logic/load/file_downloader.dart';
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
      //log(card['front'])
      //print("front media: " + card['front_media'][0]);
      parsedData.add(StudyCard(
          front: card['front_text'],
          back: card['back_text'],
          frontMedia: card['front_media'].isNotEmpty
              ? path.join(appPath.toString(), deckName, card['front_media'][0])
              : '',
          backMedia: card['back_media'].isNotEmpty
              ? path.join(appPath.toString(), deckName, card['back_media'][0])
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
    //print("back 1: " + parsedData[0].back);
    return parsedData;
  }

  // convert a list of StudyCard objects to a json string using the format:
  // {"deckName": "name", "length": 1, "cards": [{"front_text": "","back_text": "","front_media": [],"back_media": []}, ...]}
  static String convertToJson(String deck_name, List<StudyCard> cards) {
    final deckName = deck_name;
    final deckLength = cards.length;
    final List<Map<String, dynamic>> cardList = [];
    for (var i = 0; i < cards.length; i++) {
      final card = cards[i];
      final Map<String, dynamic> cardMap = {
        'front_text': card.front,
        'back_text': card.back,
        'front_media': card.frontMedia.isNotEmpty ? [card.frontMedia] : [],
        'back_media': card.backMedia.isNotEmpty ? [card.backMedia] : []
      };
      cardList.add(cardMap);
    }
    final Map<String, dynamic> deckMap = {
      'deckName': deckName,
      'length': deckLength,
      'cards': cardList
    };
    return prettifyJsonEncode(deckMap);
  }

  /// Saves the XML string to a file.
  static Future<bool> saveJSONToFile(
      String jsonString, String fileName, Map<String, String> mediaMap) async {
    return FileDownloader.saveFileOnDevice(fileName, jsonString, mediaMap);
  }
}
