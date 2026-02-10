import 'dart:convert';
import 'dart:io';

import 'package:flutter_launcher_icons/utils.dart';
import 'package:study_cards/src/data/model/card/study_card.dart';
import 'package:study_cards/src/logic/load/file_downloader.dart';
import 'package:study_cards/src/logic/media/image_converter.dart';
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
  /// Supports both current format (single media string) and legacy format (media array)
  static Future<List<StudyCard>> parseJson(String jsonString) async {
    final jsonData = jsonDecode(jsonString);
    final deckName = jsonData['deckName'];
    List<StudyCard> parsedData = [];
    parsedData
        .add(StudyCard(front: deckName, back: jsonData['cards'].length.toString()));
    for (var card in jsonData['cards']) {
      String frontMedia = '';
      String backMedia = '';
      if (card['front_media'] != null) {
        if (card['front_media'] is List) {
          frontMedia = '';
        } else if (card['front_media'] is String) {
          frontMedia = card['front_media'];
        }
      }
      if (card['back_media'] != null) {
        if (card['back_media'] is List) {
          backMedia = '';
        } else if (card['back_media'] is String) {
          backMedia = card['back_media'];
        }
      }
      parsedData.add(StudyCard(
          front: card['front_text'],
          back: card['back_text'],
          frontMedia: frontMedia,
          backMedia: backMedia));
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

  /// Parse legacy JSON format (from ZIP files) with image arrays
  static Future<List<StudyCard>> parseLegacyJson(
      String jsonString, String basePath, Map<String, File> imageFiles) async {
    final jsonData = jsonDecode(jsonString);
    final deckName = jsonData['deckName'];
    List<StudyCard> parsedData = [];
    final cardsLength = jsonData['length'] ?? jsonData['cards'].length;
    parsedData.add(StudyCard(front: deckName, back: cardsLength.toString()));
    for (var card in jsonData['cards']) {
      String frontMedia = '';
      String backMedia = '';
      if (card['front_media'] != null) {
        if (card['front_media'] is List && (card['front_media'] as List).isNotEmpty) {
          final imageName = (card['front_media'] as List).first;
          if (imageFiles.containsKey(imageName)) {
            frontMedia = await ImageConverter.fileToBase64(imageFiles[imageName]!);
          }
        } else if (card['front_media'] is String) {
          frontMedia = card['front_media'];
        }
      }
      if (card['back_media'] != null) {
        if (card['back_media'] is List && (card['back_media'] as List).isNotEmpty) {
          final imageName = (card['back_media'] as List).first;
          if (imageFiles.containsKey(imageName)) {
            backMedia = await ImageConverter.fileToBase64(imageFiles[imageName]!);
          }
        } else if (card['back_media'] is String) {
          backMedia = card['back_media'];
        }
      }
      parsedData.add(StudyCard(
          front: card['front_text'],
          back: card['back_text'],
          frontMedia: frontMedia,
          backMedia: backMedia));
    }
    return parsedData;
  }

  /// Parse legacy XML format (from ZIP files) with external image files
  static Future<List<StudyCard>> parseLegacyXml(
      String xmlString, String basePath, Map<String, File> imageFiles) async {
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
      String frontMedia = '';
      String backMedia = '';
      var frontMediaElement = card.findElements('media').firstWhere(
          (element) =>
              element.getAttribute('type') == 'image' &&
              element.getAttribute('name') == 'Front',
          orElse: () => xml.XmlElement(xml.XmlName('media'), [], []));
      var frontMediaSrc = frontMediaElement.getAttribute('src');
      if (frontMediaSrc != null && imageFiles.containsKey(frontMediaSrc)) {
        frontMedia = await ImageConverter.fileToBase64(imageFiles[frontMediaSrc]!);
      }
      var backMediaElement = card.findElements('media').firstWhere(
          (element) =>
              element.getAttribute('type') == 'image' &&
              element.getAttribute('name') == 'Back',
          orElse: () => xml.XmlElement(xml.XmlName('media'), [], []));
      
      var backMediaSrc = backMediaElement.getAttribute('src');
      if (backMediaSrc != null && imageFiles.containsKey(backMediaSrc)) {
        backMedia = await ImageConverter.fileToBase64(imageFiles[backMediaSrc]!);
      }
      parsedData.add(StudyCard(
          front: front,
          back: back,
          frontMedia: frontMedia,
          backMedia: backMedia));
    }
    return parsedData;
  }
}
