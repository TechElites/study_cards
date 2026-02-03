import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_cards/src/logic/load/extension_handler.dart';

void main() {
  group('Legacy Format Compatibility Tests', () {
    test('parseJson should handle legacy array format for media', () async {
      // Legacy JSON with array format for images
      final legacyJson = jsonEncode({
        'deckName': 'Test Deck',
        'length': 2,
        'cards': [
          {
            'front_text': 'Question 1',
            'back_text': 'Answer 1',
            'front_media': ['1_front.png'],
            'back_media': ['1_back.jpg']
          },
          {
            'front_text': 'Question 2',
            'back_text': 'Answer 2',
            'front_media': [],
            'back_media': []
          }
        ]
      });

      final cards = await ExtensionHandler.parseJson(legacyJson);

      // First card is the deck info
      expect(cards.length, 3);
      expect(cards[0].front, 'Test Deck');
      expect(cards[0].back, '2');

      // Check that array format is handled (should be empty since no ZIP)
      expect(cards[1].front, 'Question 1');
      expect(cards[1].back, 'Answer 1');
      expect(cards[1].frontMedia, ''); // Arrays are ignored in non-ZIP files
      expect(cards[1].backMedia, '');

      expect(cards[2].front, 'Question 2');
      expect(cards[2].back, 'Answer 2');
      expect(cards[2].frontMedia, '');
      expect(cards[2].backMedia, '');
    });

    test('parseJson should handle current string format for media', () async {
      // Current JSON with base64 string format
      final currentJson = jsonEncode({
        'deckName': 'Modern Deck',
        'cards': [
          {
            'front_text': 'Question 1',
            'back_text': 'Answer 1',
            'front_media': 'base64encodedimage',
            'back_media': ''
          },
          {
            'front_text': 'Question 2',
            'back_text': 'Answer 2',
            'front_media': '',
            'back_media': 'anotherbase64image'
          }
        ]
      });

      final cards = await ExtensionHandler.parseJson(currentJson);

      // First card is the deck info
      expect(cards.length, 3);
      expect(cards[0].front, 'Modern Deck');
      expect(cards[0].back, '2');

      // Check that string format is handled correctly
      expect(cards[1].front, 'Question 1');
      expect(cards[1].back, 'Answer 1');
      expect(cards[1].frontMedia, 'base64encodedimage');
      expect(cards[1].backMedia, '');

      expect(cards[2].front, 'Question 2');
      expect(cards[2].back, 'Answer 2');
      expect(cards[2].frontMedia, '');
      expect(cards[2].backMedia, 'anotherbase64image');
    });

    test('parseJson should handle missing media fields', () async {
      // JSON without media fields
      final minimalJson = jsonEncode({
        'deckName': 'Minimal Deck',
        'cards': [
          {
            'front_text': 'Question',
            'back_text': 'Answer'
          }
        ]
      });

      final cards = await ExtensionHandler.parseJson(minimalJson);

      expect(cards.length, 2);
      expect(cards[1].frontMedia, '');
      expect(cards[1].backMedia, '');
    });

    test('parseJson should handle mixed formats', () async {
      // Mixed JSON with some legacy arrays and some modern strings
      final mixedJson = jsonEncode({
        'deckName': 'Mixed Deck',
        'cards': [
          {
            'front_text': 'Q1',
            'back_text': 'A1',
            'front_media': ['legacy.png'],
            'back_media': 'base64string'
          },
          {
            'front_text': 'Q2',
            'back_text': 'A2',
            'front_media': 'base64string',
            'back_media': ['legacy.jpg']
          }
        ]
      });

      final cards = await ExtensionHandler.parseJson(mixedJson);

      expect(cards.length, 3);
      
      // Array is ignored, string is kept
      expect(cards[1].frontMedia, '');
      expect(cards[1].backMedia, 'base64string');

      // String is kept, array is ignored
      expect(cards[2].frontMedia, 'base64string');
      expect(cards[2].backMedia, '');
    });
  });
}
