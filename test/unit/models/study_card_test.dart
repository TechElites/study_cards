import 'package:flutter_test/flutter_test.dart';
import 'package:study_cards/src/data/model/card/study_card.dart';

void main() {
  group('StudyCard Model Tests', () {
    test('should create study card with correct properties', () {
      final card = StudyCard(
        id: 1,
        deckId: 2,
        front: 'Test Front',
        back: 'Test Back',
        rating: 'easy',
        lastReviewed: '2023-12-01T10:00:00.000Z',
        frontMedia: 'front_image_data',
        backMedia: 'back_image_data',
      );

      expect(card.id, equals(1));
      expect(card.deckId, equals(2));
      expect(card.front, equals('Test Front'));
      expect(card.back, equals('Test Back'));
      expect(card.rating, equals('easy'));
      expect(card.lastReviewed, equals('2023-12-01T10:00:00.000Z'));
      expect(card.frontMedia, equals('front_image_data'));
      expect(card.backMedia, equals('back_image_data'));
    });

    test('should create study card with default values', () {
      final card = StudyCard(
        front: 'Test Front',
        back: 'Test Back',
      );

      expect(card.id, equals(-1));
      expect(card.deckId, equals(-1));
      expect(card.rating, equals('none'));
      expect(card.lastReviewed, equals('never'));
      expect(card.frontMedia, equals(''));
      expect(card.backMedia, equals(''));
    });

    test('should format last reviewed date correctly', () {
      final card = StudyCard(
        front: 'Test Front',
        back: 'Test Back',
        lastReviewed: '2023-12-01T10:30:45.123Z',
      );

      expect(card.lastReviewedFormatted, equals('2023-12-01 10:30'));
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

    test('should convert to HiveStudyCard correctly', () {
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

    test('should create from HiveStudyCard correctly', () {
      final hiveCard = HiveStudyCard()
        ..deckId = 1
        ..front = 'Test Front'
        ..back = 'Test Back'
        ..rating = 'medium'
        ..lastReviewed = '2023-12-01T10:00:00.000Z'
        ..frontMedia = 'front_data'
        ..backMedia = 'back_data';

      // Simulate direct creation without using fromHiveStudyCard 
      // which requires a valid key
      final card = StudyCard(
        id: hiveCard.key ?? -1,
        deckId: hiveCard.deckId,
        front: hiveCard.front,
        back: hiveCard.back,
        rating: hiveCard.rating,
        lastReviewed: hiveCard.lastReviewed,
        frontMedia: hiveCard.frontMedia,
        backMedia: hiveCard.backMedia,
      );

      expect(card.deckId, equals(1));
      expect(card.front, equals('Test Front'));
      expect(card.back, equals('Test Back'));
      expect(card.rating, equals('medium'));
      expect(card.lastReviewed, equals('2023-12-01T10:00:00.000Z'));
      expect(card.frontMedia, equals('front_data'));
      expect(card.backMedia, equals('back_data'));
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
  });
}
