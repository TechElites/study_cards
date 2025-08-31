import 'package:flutter_test/flutter_test.dart';
import 'package:flash_cards/src/logic/deck/deck_shuffler.dart';
import 'package:flash_cards/src/data/model/card/study_card.dart';

void main() {
  group('DeckShuffler Tests', () {
    test('should shuffle cards maintaining all elements', () {
      final originalCards = [
        StudyCard(front: 'Card 1', back: 'Answer 1'),
        StudyCard(front: 'Card 2', back: 'Answer 2'),
        StudyCard(front: 'Card 3', back: 'Answer 3'),
        StudyCard(front: 'Card 4', back: 'Answer 4'),
        StudyCard(front: 'Card 5', back: 'Answer 5'),
      ];

      final shuffledCards = DeckShuffler.shuffleCards(originalCards, 10);

      // Verify that the number of cards is the same
      expect(shuffledCards.length, equals(originalCards.length));

      // Verify that all original cards are present
      for (final originalCard in originalCards) {
        expect(
          shuffledCards.any((card) => 
            card.front == originalCard.front && 
            card.back == originalCard.back
          ),
          isTrue,
        );
      }
    });

    test('should handle empty list', () {
      final emptyList = <StudyCard>[];
      final result = DeckShuffler.shuffleCards(emptyList, 10);
      
      expect(result, isEmpty);
    });

    test('should handle single card', () {
      final singleCard = [StudyCard(front: 'Only Card', back: 'Only Answer')];
      final result = DeckShuffler.shuffleCards(singleCard, 10);
      
      expect(result.length, equals(1));
      expect(result.first.front, equals('Only Card'));
      expect(result.first.back, equals('Only Answer'));
    });

    test('should limit cards to maxCards parameter', () {
      final cards = List.generate(10, (index) => 
        StudyCard(front: 'Card $index', back: 'Answer $index')
      );

      final shuffled = DeckShuffler.shuffleCards(cards, 5);
      
      // Verify that at most 5 cards are returned
      expect(shuffled.length, equals(5));
      
      // Verify that all returned cards are in the original list
      for (final card in shuffled) {
        expect(cards.any((c) => c.front == card.front), isTrue);
      }
    });

    test('should return all cards when maxCards is greater than available', () {
      final cards = List.generate(3, (index) => 
        StudyCard(front: 'Card $index', back: 'Answer $index')
      );

      final shuffled = DeckShuffler.shuffleCards(cards, 10);
      
      // Dovrebbe restituire tutte e 3 le carte
      expect(shuffled.length, equals(3));
    });

    test('should handle cards with different ratings', () {
      final cards = [
        StudyCard(front: 'Easy Card', back: 'Easy Answer', rating: 'easy'),
        StudyCard(front: 'Hard Card', back: 'Hard Answer', rating: 'hard'),
        StudyCard(front: 'Medium Card', back: 'Medium Answer', rating: 'medium'),
        StudyCard(front: 'None Card', back: 'None Answer', rating: 'none'),
      ];

      final shuffledCards = DeckShuffler.shuffleCards(cards, 10);

      // Verify that all ratings are preserved
      final originalRatings = cards.map((card) => card.rating).toSet();
      final shuffledRatings = shuffledCards.map((card) => card.rating).toSet();
      
      expect(shuffledRatings, equals(originalRatings));
    });

    test('should handle cards with media', () {
      final cards = [
        StudyCard(
          front: 'Card with media',
          back: 'Answer with media',
          frontMedia: 'front_image_data',
          backMedia: 'back_image_data',
        ),
        StudyCard(front: 'Card without media', back: 'Answer without media'),
      ];

      final shuffledCards = DeckShuffler.shuffleCards(cards, 10);

      // Verify that media are preserved
      final cardWithMedia = shuffledCards.firstWhere(
        (card) => card.frontMedia.isNotEmpty
      );
      
      expect(cardWithMedia.frontMedia, equals('front_image_data'));
      expect(cardWithMedia.backMedia, equals('back_image_data'));
    });

    test('should handle timed card shuffling', () {
      final now = DateTime.now();
      final oldTime = now.subtract(const Duration(hours: 2));
      
      final cards = [
        StudyCard(
          front: 'Old Card',
          back: 'Old Answer',
          rating: 'easy',
          lastReviewed: oldTime.toIso8601String(),
        ),
        StudyCard(
          front: 'New Card',
          back: 'New Answer',
          rating: 'easy',
          lastReviewed: now.toIso8601String(),
        ),
      ];

      final timedShuffled = DeckShuffler.shuffleTimedCards(cards, 10);
      
      // Verify that the method does not throw errors
      expect(timedShuffled, isA<List<StudyCard>>());
    });

    test('should return fail cards when no timed cards available', () {
      final now = DateTime.now();
      
      final cards = [
        StudyCard(
          front: 'Recent Easy Card',
          back: 'Recent Easy Answer',
          rating: 'easy',
          lastReviewed: now.toIso8601String(),
        ),
        StudyCard(
          front: 'Failed Card',
          back: 'Failed Answer',
          rating: 'fail',
          lastReviewed: now.subtract(const Duration(hours: 1)).toIso8601String(),
        ),
      ];

      final timedShuffled = DeckShuffler.shuffleTimedCards(cards, 10);
      
      // Dovrebbe includere almeno la carta fail se non ci sono altre carte disponibili
      expect(timedShuffled, isNotEmpty);
    });
  });
}
