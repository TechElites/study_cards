import 'package:flash_cards/src/logic/platform_helper.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flash_cards/src/data/model/deck/deck.dart';
import 'package:flash_cards/src/data/model/card/study_card.dart';
import 'package:path_provider/path_provider.dart';

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
    if (PlatformHelper.isDesktop) {
      final dir = await getApplicationSupportDirectory();
      await Hive.openBox<HiveDeck>('decks', path: dir.path);
      await Hive.openBox<HiveStudyCard>('cards', path: dir.path);
    } else {
      await Hive.openBox<HiveDeck>('decks');
      await Hive.openBox<HiveStudyCard>('cards');
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
