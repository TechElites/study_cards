import 'package:hive_flutter/hive_flutter.dart';
import 'package:flash_cards/src/data/model/deck/deck.dart';
import 'package:flash_cards/src/data/model/card/study_card.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(HiveDeckAdapter());
    Hive.registerAdapter(HiveStudyCardAdapter());
    await Hive.openBox<HiveDeck>('decks');
    await Hive.openBox<HiveStudyCard>('cards');
  }

  Box<HiveDeck> get decksBox => Hive.box<HiveDeck>('decks');
  Box<HiveStudyCard> get cardsBox => Hive.box<HiveStudyCard>('cards');

  Future<int> insertDeck(Deck deck) async {
    return await decksBox.add(deck.toHiveDeck());
  }

  Future<void> insertCard(StudyCard card) async {
    await cardsBox.add(card.toHiveStudyCard());
    final deck = decksBox.values.firstWhere((d) => d.key == card.deckId);
    deck.cards += 1;
    await deck.save();
  }

  Future<void> insertDeckCards(List<StudyCard> cards) async {
    for (var card in cards) {
      await cardsBox.add(card.toHiveStudyCard());
    }
  }

  List<Deck> getDecks() {
    return decksBox.values.map((deck) => Deck.fromHiveDeck(deck)).toList();
  }

  Deck getDeck(int deckId) {
    return Deck.fromHiveDeck(
        decksBox.values.firstWhere((deck) => deck.key == deckId));
  }

  List<StudyCard> getCards(int deckId) {
    return cardsBox.values
        .where((card) => card.deckId == deckId)
        .map((card) => StudyCard.fromHiveStudyCard(card))
        .toList();
  }

  int getReviewCards(int deckId) {
    return decksBox.values.firstWhere((deck) => deck.key == deckId).reviewCards;
  }

  Future<void> setReviewCards(int deckId, int reviewCards) async {
    final deck = decksBox.values.firstWhere((deck) => deck.key == deckId);
    deck.reviewCards = reviewCards;
    await deck.save();
  }

  Future<void> updateDeckName(int deckId, String name) async {
    final deck = decksBox.values.firstWhere((deck) => deck.key == deckId);
    deck.name = name;
    await deck.save();
  }

  Future<void> updateCard(StudyCard card) async {
    final existingCard = cardsBox.values.firstWhere((c) => c.key == card.id);
    existingCard.front = card.front;
    existingCard.back = card.back;
    existingCard.rating = card.rating;
    existingCard.lastReviewed = card.lastReviewed;
    existingCard.frontMedia = card.frontMedia;
    existingCard.backMedia = card.backMedia;
    await existingCard.save();
  }

  Future<void> updateCardRating(int cardId, String rating) async {
    final card = cardsBox.values.firstWhere((c) => c.key == cardId);
    card.rating = rating;
    card.lastReviewed = DateTime.now().toIso8601String();
    await card.save();
  }

  Future<void> deleteDeck(int deckId) async {
    final deck = decksBox.values.firstWhere((deck) => deck.key == deckId);
    await deck.delete();
    final cards =
        cardsBox.values.where((card) => card.deckId == deckId).toList();
    for (var card in cards) {
      await card.delete();
    }
  }

  Future<void> deleteDecks(List<int> deckIds) async {
    for (var deckId in deckIds) {
      await deleteDeck(deckId);
    }
  }

  Future<void> deleteCards(List<int> cardIds) async {
    final card = cardsBox.values.firstWhere((card) => card.key == cardIds[0]);
    final deckId = card.deckId;
    final deck = decksBox.values.firstWhere((deck) => deck.key == deckId);
    deck.cards -= cardIds.length;
    await deck.save();
    for (var cardId in cardIds) {
      final card = cardsBox.values.firstWhere((c) => c.key == cardId);
      await card.delete();
    }
  }

  Future<void> deleteCard(int cardId) async {
    final card = cardsBox.values.firstWhere((c) => c.key == cardId);
    final deckId = card.deckId;
    await card.delete();
    final deck = decksBox.values.firstWhere((deck) => deck.key == deckId);
    deck.cards -= 1;
    await deck.save();
  }
}
