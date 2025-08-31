import 'dart:convert';

import 'package:flutter_launcher_icons/utils.dart';
import 'package:flash_cards/src/data/model/card/study_card.dart';
import 'package:flash_cards/src/logic/load/file_downloader.dart';
import 'package:xml/xml.dart' as xml;

/// Handles the XML and JSON data.
class ExtensionHandler {
  /// Parses the XML string and returns a list of [StudyCard].
  static Future<List<StudyCard>> parseXml(String xmlString) async {
    xmlString = xmlString.replaceAll('\n', '');
    xmlString = xmlString.replaceAll('  ', '');
    final document = xml.XmlDocument.parse(xmlString);
    final cards = document.findAllElements('card');

    List<StudyCard> parsedData = [];

    final deckName =
        document.findAllElements('deck').first.attributes.first.value;
    parsedData.add(StudyCard(front: deckName, back: cards.length.toString()));

    for (var card in cards) {
      final front = card
          .findElements('rich-text')
          .firstWhere((element) => element.getAttribute('name') == 'Front')
          .innerXml
          .replaceAll('<br/>', '\n');
      final back = card
          .findElements('rich-text')
          .firstWhere((element) => element.getAttribute('name') == 'Back')
          .innerXml
          .replaceAll('<br/>', '\n');
      parsedData.add(StudyCard(
          front: front,
          back: back));
    }
    return parsedData;
  }

  /// Creates an XML string from a list of [StudyCard].
  static String createXml(List<StudyCard> cards, String deckName) {
    final builder = xml.XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('deck', nest: () {
      builder.attribute('name', deckName);
      builder.element('cards', nest: () {
        for (var card in cards) {
          builder.element('card', nest: () {
            builder.element('rich-text', nest: () {
              builder.attribute('name', 'Front');
              String front = card.front;
              if (front.contains('\n')) {
                for (String s in front.split('\n')) {
                  builder.text(s);
                  builder.element('br');
                }
              }
              builder.text(front);
            });
            builder.element('rich-text', nest: () {
              builder.attribute('name', 'Back');
              final String back = card.back;
              if (back.contains('\n')) {
                for (String s in back.split('\n')) {
                  builder.text(s);
                  builder.element('br');
                }
              }
              builder.text(back);
            });
          });
        }
      });
    });

    final document = builder.buildDocument();
    return document.toXmlString(pretty: true, indent: '  ');
  }

  /// Saves the XML string to a file.
  static Future<bool> saveXmlToFile(
      String xmlString, String fileName, Map<String, String> mediaMap) async {
    return FileDownloader.saveFileOnDevice(fileName, xmlString, mediaMap);
  }

  /// Parse the json string and return a list of StudyCard objects
  static Future<List<StudyCard>> parseJson(String jsonString) async {
    final jsonData = jsonDecode(jsonString);
    final deckName = jsonData['deckName'];
    List<StudyCard> parsedData = [];
    parsedData
        .add(StudyCard(front: deckName, back: jsonData['cards'].length.toString()));
    
    for (var card in jsonData['cards']) {
      parsedData.add(StudyCard(
          front: card['front_text'],
          back: card['back_text'],
          frontMedia: card['front_media'] ?? '',
          backMedia: card['back_media'] ?? ''));
    }
    return parsedData;
  }

  // convert a list of StudyCard objects to a json string using the format:
  // {
  //   "deckName": "name",
  //   "cards": [
  //              {
  //                "front_text": "",
  //                "back_text": "",
  //                "front_media": "",
  //                "back_media": ""
  //              }, 
  //         ...]
  // }
  static String convertToJson(String deckName, List<StudyCard> cards) {
    final List<Map<String, dynamic>> cardList = [];
    for (var i = 0; i < cards.length; i++) {
      final card = cards[i];
      final Map<String, dynamic> cardMap = {
        'front_text': card.front,
        'back_text': card.back,
        'front_media': card.frontMedia,
        'back_media': card.backMedia
      };
      cardList.add(cardMap);
    }
    final Map<String, dynamic> deckMap = {
      'deckName': deckName,
      'cards': cardList
    };
    return prettifyJsonEncode(deckMap);
  }

  /// Saves the JSON string to a file.
  static Future<bool> saveJSONToFile(String jsonString, String fileName) async {
    return FileDownloader.saveFileOnDevice(fileName, jsonString, {});
  }
}
