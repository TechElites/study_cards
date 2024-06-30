import 'package:flash_cards/src/data/model/card/study_card.dart';
import 'package:flash_cards/src/logic/downloader/file_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart' as xml;
import 'package:path/path.dart' as path;

/// Handles the XML data.
class XmlHandler {
  /// Parses the XML string with images and returns a list of [StudyCard].
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
      var frontMedia = card
          .findElements('media')
          .firstWhere(
              (element) =>
                  element.getAttribute('type') == 'image' &&
                  element.getAttribute('name') == 'Front',
              orElse: () => xml.XmlElement(xml.XmlName('media'), [], []))
          .getAttribute('src');
      final back = card
          .findElements('rich-text')
          .firstWhere((element) => element.getAttribute('name') == 'Back')
          .innerXml
          .replaceAll('<br/>', '\n');
      var backMedia = card
          .findElements('media')
          .firstWhere(
              (element) =>
                  element.getAttribute('type') == 'image' &&
                  element.getAttribute('name') == 'Back',
              orElse: () => xml.XmlElement(xml.XmlName('media'), [], []))
          .getAttribute('src');
      var appPath = '';
      final directory = await getExternalStorageDirectory();
      appPath = directory!.path;
      frontMedia = frontMedia != null
          ? path.join(appPath.toString(), deckName, frontMedia)
          : '';
      backMedia = backMedia != null
          ? path.join(appPath.toString(), deckName, backMedia)
          : '';
      parsedData.add(StudyCard(
          front: front,
          back: back,
          frontMedia: frontMedia,
          backMedia: backMedia));
    }
    return parsedData;
  }

  /// Parses the XML string and returns a list of [StudyCard].
  static Future<List<StudyCard>> parseSimpleXml(String xmlString) async {
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
      parsedData.add(StudyCard(front: front, back: back));
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
            if (card.frontMedia.isNotEmpty) {
              builder.element('media', nest: () {
                builder.attribute('type', 'image');
                builder.attribute('name', 'Front');
                builder.attribute('src',
                    '${card.id}_front.${card.frontMedia.split('.').last}');
              });
            }
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
            if (card.backMedia.isNotEmpty) {
              builder.element('media', nest: () {
                builder.attribute('type', 'image');
                builder.attribute('name', 'Back');
                builder.attribute(
                    'src', '${card.id}_back.${card.backMedia.split('.').last}');
              });
            }
          });
        }
      });
    });

    final document = builder.buildDocument();
    return document.toXmlString(pretty: true, indent: '  ');
  }

  /// Saves the XML string to a file.
  static Future<void> saveXmlToFile(
      String xmlString, String fileName, Map<String, String> mediaMap) async {
    FileDownloader.saveFileOnDevice(fileName, xmlString, mediaMap);
  }
}
