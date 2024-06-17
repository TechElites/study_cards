import 'package:flash_cards/src/data/model/card.dart';
import 'package:flash_cards/src/logic/file_downloader_helper.dart';
import 'package:xml/xml.dart' as xml;

class XmlHandler {
  static List<Map<String, String>> parseXml(String xmlString) {
    final document = xml.XmlDocument.parse(xmlString);
    final cards = document.findAllElements('card');

    List<Map<String, String>> parsedData = [];

    final deckName =
        document.findAllElements('deck').first.attributes.first.value;
    parsedData.add({'deck': deckName, 'cards': cards.length.toString()});

    for (var card in cards) {
      final front = card.children.first.firstChild?.value ?? '';
      final back = card.children.last.firstChild?.value ?? '';
      parsedData.add({'question': front, 'answer': back});
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
              builder.text(card.question);
            });
            builder.element('rich-text', nest: () {
              builder.attribute('name', 'Back');
              builder.text(card.answer);
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
