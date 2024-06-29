import 'package:flash_cards/src/data/model/rating.dart';
import 'package:flash_cards/src/data/model/card/study_card.dart';

class DeckShuffler {
  static List<StudyCard> shuffleTimedCards(List<StudyCard> cards, int maxCards) {
    final List<StudyCard> shuffledCards = [];

    for (final card in cards) {
      if (card.minutesSinceReviewed >= Rating.times[card.rating]) {
        shuffledCards.add(card);
      }
    }

    if (shuffledCards.isEmpty) {
      shuffledCards.addAll(cards.where((c) => c.rating == Rating.fail));
    }

    return shuffleCards(shuffledCards, maxCards);
  }

  static List<StudyCard> shuffleCards(List<StudyCard> cards, int maxCards) {
    final List<StudyCard> shuffledCards = cards;

    shuffledCards.shuffle();

    return shuffledCards.length > maxCards
        ? shuffledCards.sublist(0, maxCards)
        : shuffledCards;
  }
}
