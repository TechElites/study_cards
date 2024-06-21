import 'package:flash_cards/src/data/model/deck.dart';
import 'package:flash_cards/src/data/model/study_card.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'decks.db');

    // Uncomment first time when upgrading db
    // await deleteDatabase(path);

    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE decks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            cards INTEGER,
            reviewCards INTEGER,
            creation TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE cards (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            deckId INTEGER,
            front TEXT,
            back TEXT,
            rating TEXT,
            lastReviewed TEXT,
            FOREIGN KEY (deckId) REFERENCES decks (id)
          )
        ''');
      },
    );
  }

  Future<int> insertDeck(Deck deck) async {
    Database db = await database;
    return await db.insert('decks', deck.toMap());
  }

  Future<int> insertCard(StudyCard card) async {
    Database db = await database;
    await db.insert('cards', card.toMap());
    return await db.rawUpdate('''
      UPDATE decks
      SET cards = cards + 1
      WHERE id = ?
    ''', [card.deckId]);
  }

  Future<List<Deck>> getDecks() async {
    Database db = await database;
    List<Map<String, Object?>> rawDecks = await db.query('decks');
    return rawDecks.map((deck) => Deck.fromMap(deck)).toList();
  }

  Future<List<StudyCard>> getCards(int deckId) async {
    Database db = await database;
    List<Map<String, Object?>> rawCards = await db.query('cards', where: 'deckId = ?', whereArgs: [deckId]);
    return rawCards.map((card) => StudyCard.fromMap(card)).toList();
  }

  Future<int> getReviewCards(int deckId) async {
    Database db = await database;
    List<Map<String, Object?>> rawDecks = await db.query('decks', where: 'id = ?', whereArgs: [deckId]);
    return rawDecks[0]['reviewCards'] as int;
  }

  Future<void> setReviewCards(int deckId, int reviewCards) async {
    Database db = await database;
    await db.update('decks', {'reviewCards': reviewCards}, where: 'id = ?', whereArgs: [deckId]);
  }

  Future<void> updateCardRating(int cardId, String rating) async {
    Database db = await database;
    await db.update('cards', {
      'rating': rating,
      'lastReviewed': DateTime.now().toIso8601String(),
    }, where: 'id = ?', whereArgs: [cardId]);
  }

  Future<void> deleteDeck(int deckId) async {
    Database db = await database;
    await db.delete('decks', where: 'id = ?', whereArgs: [deckId]);
    await db.delete('cards', where: 'deckId = ?', whereArgs: [deckId]);
  }

  Future<void> deleteCard(int cardId) async {
    Database db = await database;
    await db.rawUpdate('''
      UPDATE decks
      SET cards = cards - 1
      WHERE id = (
        SELECT deckId
        FROM cards
        WHERE id = ?
      )
    ''', [cardId]);
    await db.delete('cards', where: 'id = ?', whereArgs: [cardId]);
  }
}
