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
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE decks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            cards INTEGER,
            creation TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE cards (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            deckId INTEGER,
            question TEXT,
            answer TEXT,
            rating TEXT,
            lastReviewed TEXT,
            FOREIGN KEY (deckId) REFERENCES decks (id)
          )
        ''');
      },
    );
  }

  Future<int> insertDeck(Map<String, dynamic> deck) async {
    Database db = await database;
    return await db.insert('decks', deck);
  }

  Future<int> insertCard(Map<String, dynamic> card) async {
    Database db = await database;
    return await db.insert('cards', card);
  }

  Future<List<Map<String, dynamic>>> getDecks() async {
    Database db = await database;
    return await db.query('decks');
  }

  Future<List<Map<String, dynamic>>> getCards(int deckId) async {
    Database db = await database;
    return await db.query('cards', where: 'deckId = ?', whereArgs: [deckId]);
  }

  Future<void> deleteDeck(int deckId) async {
    Database db = await database;
    await db.delete('decks', where: 'id = ?', whereArgs: [deckId]);
    await db.delete('cards', where: 'deckId = ?', whereArgs: [deckId]);
  }

  Future<void> deleteCard(int cardId) async {
    Database db = await database;
    await db.delete('cards', where: 'id = ?', whereArgs: [cardId]);
  }
}
