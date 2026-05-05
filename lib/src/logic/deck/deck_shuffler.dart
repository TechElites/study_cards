import 'dart:math';
import 'package:study_cards/src/data/model/rating.dart';
import 'package:study_cards/src/data/model/card/study_card.dart';

class DeckShuffler {
  static const double _decay = 0.5;
  static const double _factor = 0.9;
  static const double _desiredRetention = 0.9;

  static List<StudyCard> shuffleTimedCardsAnki(
      List<StudyCard> cards, int maxCards) {
    final dueCards = _getDueCards(cards);

    if (dueCards.isEmpty) {
      dueCards.addAll(cards.where((c) => c.rating == Rating.fail));
    }

    dueCards.sort((a, b) => _getRetrievability(b).compareTo(_getRetrievability(a)));
    dueCards.shuffle();

    return dueCards.length > maxCards
        ? dueCards.sublist(0, maxCards)
        : dueCards;
  }

  static List<StudyCard> _getDueCards(List<StudyCard> cards) {
    return cards.where((card) => _isDue(card)).toList();
  }

  static bool _isDue(StudyCard card) {
    if (card.lastReviewed == 'never') return true;
    return _getRetrievability(card) < _desiredRetention;
  }

  static double _getRetrievability(StudyCard card) {
    if (card.lastReviewed == 'never') return 0.0;

    final elapsedDays = _getDaysSinceReview(card).toDouble();
    final stability = _getStability(card);

    if (stability == 0) return 0.0;

    return pow(1 + _decay * elapsedDays / stability, -_factor).toDouble();
  }

  static int _getDaysSinceReview(StudyCard card) {
    if (card.lastReviewed == 'never') return 0;
    final now = DateTime.now();
    final last = DateTime.parse(card.lastReviewed);
    return now.difference(last).inDays;
  }

  static double _getStability(StudyCard card) {
    switch (card.rating) {
      case 'fail':
        return 1.0;
      case 'hard':
        return 3.0;
      case 'good':
        return 10.0;
      case 'easy':
        return 30.0;
      case 'none':
        return 0.0;
      default:
        return 1.0;
    }
  }

  static List<StudyCard> shuffleCards(List<StudyCard> cards, int maxCards) {
    final shuffledCards = [...cards];
    shuffledCards.shuffle();

    return shuffledCards.length > maxCards
        ? shuffledCards.sublist(0, maxCards)
        : shuffledCards;
  }

  @Deprecated('Use shuffleTimedCardsAnki() instead')
  static List<StudyCard> shuffleTimedCards(
      List<StudyCard> cards, int maxCards) {
    return shuffleTimedCardsAnki(cards, maxCards);
  }
}
