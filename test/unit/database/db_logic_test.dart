import 'package:flutter_test/flutter_test.dart';
import 'package:study_cards/src/data/model/deck/deck.dart';
import 'package:study_cards/src/data/model/card/study_card.dart';

void main() {
  group('DatabaseHelper Logic Tests', () {
    test('should create deck with correct properties', () {
      final now = DateTime.now();
      final deck = Deck(
        name: 'Test Deck',
        cards: 5,
        creation: now,
      );

      expect(deck.name, equals('Test Deck'));
      expect(deck.cards, equals(5));
      expect(deck.creation, equals(now));
      expect(deck.reviewCards, equals(10)); // Default value
    });

    test('should create study card with correct properties', () {
      final card = StudyCard(
        deckId: 1,
        front: 'Test Question',
        back: 'Test Answer',
        rating: 'easy',
      );

      expect(card.deckId, equals(1));
      expect(card.front, equals('Test Question'));
      expect(card.back, equals('Test Answer'));
      expect(card.rating, equals('easy'));
      expect(card.lastReviewed, equals('never'));
    });

    test('should calculate minutes since reviewed correctly', () {
      final now = DateTime.now();
      final oneHourAgo = now.subtract(const Duration(hours: 1));
      
      final card = StudyCard(
        front: 'Test Front',
        back: 'Test Back',
        lastReviewed: oneHourAgo.toIso8601String(),
      );

      final minutesSince = card.minutesSinceReviewed;
      expect(minutesSince, greaterThanOrEqualTo(59));
      expect(minutesSince, lessThanOrEqualTo(61));
    });

    test('should handle never reviewed cards', () {
      final card = StudyCard(
        front: 'Test Front',
        back: 'Test Back',
        lastReviewed: 'never',
      );

      expect(card.lastReviewedFormatted, equals('never'));
      expect(card.minutesSinceReviewed, equals(0));
    });

    test('should convert deck to HiveDeck correctly', () {
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

    test('should convert card to HiveStudyCard correctly', () {
      final card = StudyCard(
        deckId: 1,
        front: 'Test Front',
        back: 'Test Back',
        rating: 'hard',
        lastReviewed: '2023-12-01T10:00:00.000Z',
        frontMedia: 'front_data',
        backMedia: 'back_data',
      );

      final hiveCard = card.toHiveStudyCard();

      expect(hiveCard.deckId, equals(1));
      expect(hiveCard.front, equals('Test Front'));
      expect(hiveCard.back, equals('Test Back'));
      expect(hiveCard.rating, equals('hard'));
      expect(hiveCard.lastReviewed, equals('2023-12-01T10:00:00.000Z'));
      expect(hiveCard.frontMedia, equals('front_data'));
      expect(hiveCard.backMedia, equals('back_data'));
    });

    test('should handle empty media fields', () {
      final card = StudyCard(
        front: 'Test Front',
        back: 'Test Back',
      );

      expect(card.frontMedia, isEmpty);
      expect(card.backMedia, isEmpty);
    });

    test('should handle different rating values', () {
      final ratings = ['none', 'easy', 'medium', 'hard', 'fail'];
      
      for (String rating in ratings) {
        final card = StudyCard(
          front: 'Test Front',
          back: 'Test Back',
          rating: rating,
        );
        
        expect(card.rating, equals(rating));
      }
    });

    test('should format last reviewed date correctly', () {
      final card = StudyCard(
        front: 'Test Front',
        back: 'Test Back',
        lastReviewed: '2023-12-01T10:30:45.123Z',
      );

      expect(card.lastReviewedFormatted, equals('2023-12-01 10:30'));
    });

    test('should handle deck creation date', () {
      final now = DateTime.now();
      final deck = Deck(
        name: 'Date Test Deck',
        cards: 0,
        creation: now,
      );

      expect(deck.creation.year, equals(now.year));
      expect(deck.creation.month, equals(now.month));
      expect(deck.creation.day, equals(now.day));
    });
  });
}
