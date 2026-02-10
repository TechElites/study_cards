import 'package:hive_flutter/hive_flutter.dart';
import 'package:study_cards/src/data/model/deck/deck.dart';
import 'package:study_cards/src/data/model/card/study_card.dart';

/// DatabaseHelper class is a singleton class that provides methods
/// to interact with the Hive database.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  /// Initialize the Hive database and register the adapters.
  /// call this method before using any other methods.
  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(HiveDeckAdapter());
    Hive.registerAdapter(HiveStudyCardAdapter());
    await Hive.openBox<HiveDeck>('decks');
    await Hive.openBox<HiveStudyCard>('cards');
    await _validateAndFixData();
  }

  /// Validates and fixes non-conforming data in the database
  Future<void> _validateAndFixData() async {
    final cardsToDelete = <int>[];
    for (var card in cardsBox.values) {
      bool needsUpdate = false;
      if (card.front.isEmpty) {
        card.front = '';
        needsUpdate = true;
      }
      if (card.back.isEmpty) {
        card.back = '';
        needsUpdate = true;
      }
      const validRatings = ['None', 'Again', 'Hard', 'Good', 'Easy'];
      if (!validRatings.contains(card.rating)) {
        card.rating = 'None';
        needsUpdate = true;
      }
      if (card.lastReviewed.isEmpty) {
        card.lastReviewed = 'never';
        needsUpdate = true;
      }
      if (card.frontMedia.isNotEmpty && !card.frontMedia.startsWith('data:image/')) {
        card.frontMedia = '';
        needsUpdate = true;
      }
      if (card.backMedia.isNotEmpty && !card.backMedia.startsWith('data:image/')) {
        card.backMedia = '';
        needsUpdate = true;
      }
      final deckExists = decksBox.values.any((deck) => deck.key == card.deckId);
      if (!deckExists) {
        cardsToDelete.add(card.key as int);
        continue;
      }
      if (needsUpdate) {
        await card.save();
      }
    }
    for (var cardId in cardsToDelete) {
      final card = cardsBox.values.firstWhere((c) => c.key == cardId);
      await card.delete();
    }
    for (var deck in decksBox.values) {
      bool needsUpdate = false;
      if (deck.name.isEmpty) {
        deck.name = 'Unnamed Deck';
        needsUpdate = true;
      }
      final actualCardCount = cardsBox.values.where((c) => c.deckId == deck.key).length;
      if (deck.cards != actualCardCount) {
        deck.cards = actualCardCount;
        needsUpdate = true;
      }
      if (deck.reviewCards <= 0) {
        deck.reviewCards = 10;
        needsUpdate = true;
      }
      if (needsUpdate) {
        await deck.save();
      }
    }
  }

  Box<HiveDeck> get decksBox => Hive.box<HiveDeck>('decks');
  Box<HiveStudyCard> get cardsBox => Hive.box<HiveStudyCard>('cards');

  /// Clear the database.
  Future<void> clear() async {
    await decksBox.clear();
    await cardsBox.clear();
  }

  /// Insert a new deck into the database.
  Future<int> insertDeck(Deck deck) async {
    return await decksBox.add(deck.toHiveDeck());
  }

  /// Insert multiple decks into the database.
  Future<void> insertCard(StudyCard card) async {
    await cardsBox.add(card.toHiveStudyCard());
    final deck = decksBox.values.firstWhere((d) => d.key == card.deckId);
    deck.cards += 1;
    await deck.save();
  }

  /// Insert multiple decks into the database.
  Future<void> insertDeckCards(List<StudyCard> cards) async {
    for (var card in cards) {
      await cardsBox.add(card.toHiveStudyCard());
    }
  }

  /// Get all decks from the database.
  List<Deck> getDecks() {
    return decksBox.values.map((deck) => Deck.fromHiveDeck(deck)).toList();
  }

  /// Get a deck from the database.
  Deck getDeck(int deckId) {
    return Deck.fromHiveDeck(
        decksBox.values.firstWhere((deck) => deck.key == deckId));
  }

  /// Get all cards of a deck from the database.
  List<StudyCard> getCards(int deckId) {
    return cardsBox.values
        .where((card) => card.deckId == deckId)
        .map((card) => StudyCard.fromHiveStudyCard(card))
        .toList();
  }

  /// Get the number per review for a deck from the database.
  int getReviewCards(int deckId) {
    return decksBox.values.firstWhere((deck) => deck.key == deckId).reviewCards;
  }

  /// Set the number per review for a deck from the database.
  Future<void> setReviewCards(int deckId, int reviewCards) async {
    final deck = decksBox.values.firstWhere((deck) => deck.key == deckId);
    deck.reviewCards = reviewCards;
    await deck.save();
  }

  /// Updates the deck name in the database.
  Future<void> updateDeckName(int deckId, String name) async {
    final deck = decksBox.values.firstWhere((deck) => deck.key == deckId);
    deck.name = name;
    await deck.save();
  }

  /// Updates the card informations in the database.
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

  /// Updates the cards rating in the database.
  Future<void> updateCardsRating(List<int> cardId, String rating) async {
    for (var id in cardId) {
      final card = cardsBox.values.firstWhere((c) => c.key == id);
      card.rating = rating;
      card.lastReviewed = DateTime.now().toIso8601String();
      await card.save();
    }
  }

  /// Deletes the deck and all its cards from the database.
  Future<void> deleteDeck(int deckId) async {
    final deck = decksBox.values.firstWhere((deck) => deck.key == deckId);
    await deck.delete();
    final cards =
        cardsBox.values.where((card) => card.deckId == deckId).toList();
    for (var card in cards) {
      await card.delete();
    }
  }

  /// Deletes a list of decks and all their cards from the database.
  Future<void> deleteDecks(List<int> deckIds) async {
    for (var deckId in deckIds) {
      await deleteDeck(deckId);
    }
  }

  /// Deletes a list of cards from the database.
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

  /// Deletes the card from the database.
  Future<void> deleteCard(int cardId) async {
    final card = cardsBox.values.firstWhere((c) => c.key == cardId);
    final deckId = card.deckId;
    await card.delete();
    final deck = decksBox.values.firstWhere((deck) => deck.key == deckId);
    deck.cards -= 1;
    await deck.save();
  }
}
