import 'package:flash_cards/src/data/model/study_card.dart';
import 'package:flash_cards/src/logic/file_downloader_helper.dart';
import 'package:xml/xml.dart' as xml;

class XmlHandler {
  static List<StudyCard> parseXml(String xmlString) {
    final document = xml.XmlDocument.parse(xmlString);
    final cards = document.findAllElements('card');

    List<StudyCard> parsedData = [];

    final deckName =
        document.findAllElements('deck').first.attributes.first.value;
    parsedData
        .add(StudyCard(front: deckName, back: cards.length.toString()));

    for (var card in cards) {
      final front = card
          .findElements('rich-text')
          .firstWhere((element) => element.getAttribute('name') == 'Front')
          .innerText;
      final back = card
          .findElements('rich-text')
          .firstWhere((element) => element.getAttribute('name') == 'Back')
          .innerText;
      parsedData.add(StudyCard(front: front, back: back));
    }

    return parsedData;
  }

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
              builder.text(card.front);
            });
            builder.element('rich-text', nest: () {
              builder.attribute('name', 'Back');
              builder.text(card.back);
            });
          });
        }
      });
    });

    final document = builder.buildDocument();
    return document.toXmlString(pretty: true, indent: '  ');
  }

  static Future<void> saveXmlToFile(String xmlString, String fileName) async {
    FileDownloaderHelper.saveFileOnDevice(fileName, xmlString);
  }
}
