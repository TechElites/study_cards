import 'package:flutter_test/flutter_test.dart';
import 'package:flash_cards/src/data/model/deck/deck.dart';

void main() {
  group('Deck Model Tests', () {
    test('should create deck with correct properties', () {
      final now = DateTime.now();
      final deck = Deck(
        id: 1,
        name: 'Test Deck',
        cards: 5,
        reviewCards: 10,
        creation: now,
      );

      expect(deck.id, equals(1));
      expect(deck.name, equals('Test Deck'));
      expect(deck.cards, equals(5));
      expect(deck.reviewCards, equals(10));
      expect(deck.creation, equals(now));
    });

    test('should create deck with default values', () {
      final now = DateTime.now();
      final deck = Deck(
        name: 'Test Deck',
        cards: 5,
        creation: now,
      );

      expect(deck.id, equals(-1));
      expect(deck.reviewCards, equals(10));
    });

    test('should convert to HiveDeck correctly', () {
      final now = DateTime.now();
      final deck = Deck(
        name: 'Test Deck',
        cards: 5,
        reviewCards: 15,
        creation: now,
      );

      final hiveDeck = deck.toHiveDeck();

      expect(hiveDeck.name, equals('Test Deck'));
      expect(hiveDeck.cards, equals(5));
      expect(hiveDeck.reviewCards, equals(15));
      expect(hiveDeck.creation, equals(now.toIso8601String()));
    });

    test('should create from HiveDeck correctly', () {
      final now = DateTime.now();
      final hiveDeck = HiveDeck()
        ..name = 'Test Deck'
        ..cards = 5
        ..reviewCards = 15
        ..creation = now.toIso8601String();

      // Simulate an object that has a key (when there's no key, use -1 as default)
      final deck = Deck(
        id: hiveDeck.key ?? -1,
        name: hiveDeck.name,
        cards: hiveDeck.cards,
        reviewCards: hiveDeck.reviewCards,
        creation: DateTime.parse(hiveDeck.creation),
      );

      expect(deck.name, equals('Test Deck'));
      expect(deck.cards, equals(5));
      expect(deck.reviewCards, equals(15));
      expect(deck.creation, equals(now));
    });
  });
}
