import 'package:flash_cards/src/data/model/rating.dart';
import 'package:flash_cards/src/data/model/card/study_card.dart';

/// Class to shuffle the deck of cards.
class DeckShuffler {
  /// Shuffles the deck of cards based on rating times.
  static List<StudyCard> shuffleTimedCards(List<StudyCard> cards, int maxCards) {
    final List<StudyCard> shuffledCards = [];

    for (final card in cards) {
      final ratingTime = Rating.times[card.rating];
      if (ratingTime != null && card.minutesSinceReviewed >= ratingTime) {
        shuffledCards.add(card);
      }
    }

    if (shuffledCards.isEmpty) {
      shuffledCards.addAll(cards.where((c) => c.rating == Rating.fail));
    }

    return shuffleCards(shuffledCards, maxCards);
  }

  /// Shuffles the deck of cards.
  static List<StudyCard> shuffleCards(List<StudyCard> cards, int maxCards) {
    final List<StudyCard> shuffledCards = cards;

    shuffledCards.shuffle();

    return shuffledCards.length > maxCards
        ? shuffledCards.sublist(0, maxCards)
        : shuffledCards;
  }
}
