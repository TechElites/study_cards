import 'package:flash_cards/src/data/model/rating.dart';
import 'package:flash_cards/src/data/model/study_card.dart';

class CardsShuffler {
  static List<StudyCard> shuffleCards(List<StudyCard> cards, int maxCards) {
    final List<StudyCard> shuffledCards = [];

    for (final card in cards) {
      if (card.minutesSinceReviewed > Rating.times[card.rating]) {
        shuffledCards.add(card);
      }
    }

    if (shuffledCards.isEmpty) {
      shuffledCards.addAll(cards.where((c) => c.rating == Rating.fail));
    }

    shuffledCards.shuffle();

    return shuffledCards.length > maxCards
        ? shuffledCards.sublist(0, maxCards)
        : shuffledCards;
  }
}
