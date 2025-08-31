import 'package:flutter_test/flutter_test.dart';
import 'package:flash_cards/src/logic/load/extension_handler.dart';
import 'package:flash_cards/src/data/model/card/study_card.dart';
import 'dart:convert';

void main() {
  group('ExtensionHandler Tests', () {
    group('XML Parsing', () {
      test('should parse valid XML correctly', () async {
        const xmlString = '''
          <deck name="Test Deck">
            <cards>
              <card>
                <rich-text name="Front">Front 1</rich-text>
                <rich-text name="Back">Back 1</rich-text>
              </card>
              <card>
                <rich-text name="Front">Front 2</rich-text>
                <rich-text name="Back">Back 2</rich-text>
              </card>
            </cards>
          </deck>
        ''';

        final result = await ExtensionHandler.parseXml(xmlString);

        expect(result.length, equals(3)); // Deck name + 2 cards
        expect(result[0].front, equals('Test Deck'));
        expect(result[0].back, equals('2'));
        expect(result[1].front, equals('Front 1'));
        expect(result[1].back, equals('Back 1'));
        expect(result[2].front, equals('Front 2'));
        expect(result[2].back, equals('Back 2'));
      });

      test('should handle XML with line breaks', () async {
        const xmlString = '''
          <deck name="Test Deck">
            <cards>
              <card>
                <rich-text name="Front">Line 1<br/>Line 2</rich-text>
                <rich-text name="Back">Answer 1<br/>Answer 2</rich-text>
              </card>
            </cards>
          </deck>
        ''';

        final result = await ExtensionHandler.parseXml(xmlString);

        expect(result.length, equals(2));
        expect(result[1].front, contains('\n'));
        expect(result[1].back, contains('\n'));
      });

      test('should handle empty XML deck', () async {
        const xmlString = '''
          <deck name="Empty Deck">
            <cards>
            </cards>
          </deck>
        ''';

        final result = await ExtensionHandler.parseXml(xmlString);

        expect(result.length, equals(1)); // Only deck name
        expect(result[0].front, equals('Empty Deck'));
        expect(result[0].back, equals('0'));
      });
    });

    group('JSON Parsing', () {
      test('should parse valid JSON correctly', () async {
        const jsonString = '''
        {
          "deckName": "Test Deck",
          "cards": [
            {
              "front_text": "Front 1",
              "back_text": "Back 1",
              "front_media": "",
              "back_media": ""
            },
            {
              "front_text": "Front 2",
              "back_text": "Back 2",
              "front_media": "image_data",
              "back_media": ""
            }
          ]
        }
        ''';

        final result = await ExtensionHandler.parseJson(jsonString);

        expect(result.length, equals(3)); // Deck name + 2 cards
        expect(result[0].front, equals('Test Deck'));
        expect(result[0].back, equals('2'));
        expect(result[1].front, equals('Front 1'));
        expect(result[1].back, equals('Back 1'));
        expect(result[1].frontMedia, equals(''));
        expect(result[2].front, equals('Front 2'));
        expect(result[2].back, equals('Back 2'));
        expect(result[2].frontMedia, equals('image_data'));
      });

      test('should handle JSON with missing media fields', () async {
        const jsonString = '''
        {
          "deckName": "Test Deck",
          "cards": [
            {
              "front_text": "Front 1",
              "back_text": "Back 1"
            }
          ]
        }
        ''';

        final result = await ExtensionHandler.parseJson(jsonString);

        expect(result.length, equals(2));
        expect(result[1].frontMedia, equals(''));
        expect(result[1].backMedia, equals(''));
      });

      test('should handle empty JSON deck', () async {
        const jsonString = '''
        {
          "deckName": "Empty Deck",
          "cards": []
        }
        ''';

        final result = await ExtensionHandler.parseJson(jsonString);

        expect(result.length, equals(1)); // Only deck name
        expect(result[0].front, equals('Empty Deck'));
        expect(result[0].back, equals('0'));
      });
    });

    group('XML Creation', () {
      test('should create valid XML from cards', () {
        final cards = [
          StudyCard(front: 'Front 1', back: 'Back 1'),
          StudyCard(front: 'Front 2', back: 'Back 2'),
        ];

        final xmlString = ExtensionHandler.createXml(cards, 'Test Deck');

        expect(xmlString, contains('<deck name="Test Deck">'));
        expect(xmlString, contains('<rich-text name="Front">Front 1</rich-text>'));
        expect(xmlString, contains('<rich-text name="Back">Back 1</rich-text>'));
        expect(xmlString, contains('<rich-text name="Front">Front 2</rich-text>'));
        expect(xmlString, contains('<rich-text name="Back">Back 2</rich-text>'));
      });

      test('should handle multiline text in XML creation', () {
        final cards = [
          StudyCard(front: 'Line 1\nLine 2', back: 'Answer 1\nAnswer 2'),
        ];

        final xmlString = ExtensionHandler.createXml(cards, 'Test Deck');

        expect(xmlString, contains('<br/>'));
      });
    });

    group('JSON Creation', () {
      test('should create valid JSON from cards', () {
        final cards = [
          StudyCard(
            front: 'Front 1',
            back: 'Back 1',
            frontMedia: 'front_data',
            backMedia: 'back_data',
          ),
          StudyCard(
            front: 'Front 2',
            back: 'Back 2',
          ),
        ];

        final jsonString = ExtensionHandler.convertToJson('Test Deck', cards);

        expect(jsonString, contains('"deckName": "Test Deck"'));
        expect(jsonString, contains('"front_text": "Front 1"'));
        expect(jsonString, contains('"back_text": "Back 1"'));
        expect(jsonString, contains('"front_media": "front_data"'));
        expect(jsonString, contains('"back_media": "back_data"'));
        expect(jsonString, contains('"front_text": "Front 2"'));
        expect(jsonString, contains('"back_text": "Back 2"'));
      });

      test('should handle empty cards list in JSON creation', () {
        final cards = <StudyCard>[];

        final jsonString = ExtensionHandler.convertToJson('Empty Deck', cards);

        expect(jsonString, contains('"deckName": "Empty Deck"'));
        expect(jsonString, contains('"cards": []'));
      });

      test('should create proper JSON structure', () {
        final cards = [
          StudyCard(front: 'Test Front', back: 'Test Back'),
        ];

        final jsonString = ExtensionHandler.convertToJson('Test Deck', cards);
        
        // Verify that it's valid JSON
        expect(() => jsonDecode(jsonString), returnsNormally);
        
        final decoded = jsonDecode(jsonString);
        expect(decoded['deckName'], equals('Test Deck'));
        expect(decoded['cards'], isA<List>());
        expect(decoded['cards'].length, equals(1));
        expect(decoded['cards'][0]['front_text'], equals('Test Front'));
        expect(decoded['cards'][0]['back_text'], equals('Test Back'));
      });
    });

    group('Error Handling', () {
      test('should handle malformed XML', () async {
        const malformedXml = '<deck><cards><card><rich-text name="Front">Test</card></deck>';

        expect(
          () async => await ExtensionHandler.parseXml(malformedXml),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle malformed JSON', () async {
        const malformedJson = '{"deckName": "Test", "cards": [}';

        expect(
          () async => await ExtensionHandler.parseJson(malformedJson),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle XML without deck name', () async {
        const xmlWithoutName = '''
          <deck>
            <cards>
              <card>
                <rich-text name="Front">Front 1</rich-text>
                <rich-text name="Back">Back 1</rich-text>
              </card>
            </cards>
          </deck>
        ''';

        expect(
          () async => await ExtensionHandler.parseXml(xmlWithoutName),
          throwsA(isA<StateError>()),
        );
      });
    });
  });
}
