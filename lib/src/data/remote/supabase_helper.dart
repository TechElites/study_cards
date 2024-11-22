import 'dart:io';

import 'package:study_cards/src/data/model/card/study_card.dart';
import 'package:study_cards/src/logic/load/file_reader.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseHelper {
  static final SupabaseHelper _instance = SupabaseHelper._internal();
  factory SupabaseHelper() => _instance;

  SupabaseHelper._internal();

  SupabaseClient? _supabase;

  /// Initialize the Supabase client.
  /// call this method before using any other methods.
  Future<void> init() async {
    final sp = await Supabase.initialize(
      url: 'https://xwujnixizszhqkawfxie.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh3dWpuaXhpenN6aHFrYXdmeGllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzE0OTE0NjQsImV4cCI6MjA0NzA2NzQ2NH0.kfr1UQklNFVtoZqRbN3_WsqHcwheULb7Nc9dSnv-FPc',
    );
    _supabase = sp.client;
  }

  /// Lists all the files in the Supabase storage.
  Future<List<FileObject>> listDecks() async {
    final response = await _supabase?.storage.from('decks').list();
    return response ?? [];
  }

  /// Uploads a new deck to the Supabase storage.
  Future<bool> uploadDeck(File deck) async {
    final fileName = basename(deck.path);
    final decks = await listDecks();
    String? response = '';
    if (decks.any((element) => element.name == fileName)) {
      response = await _supabase?.storage.from('decks').update(fileName, deck);
    } else {
      response = await _supabase?.storage.from('decks').upload(fileName, deck);
    }
    return response != null;
  }

  /// Downloads a deck from the Supabase storage.
  Future<List<StudyCard>> downloadDeck(String deck) async {
    // if no extension is provided, try to find the deck with the zip extension
    if (!deck.contains('.')) {
      final decks = await listDecks();
      final decksNames = decks.map((e) => e.name).toList();
      deck += decksNames.contains('$deck.zip') ? '.zip' : '.json';
    }
    final intList = await _supabase?.storage.from('decks').download(deck);
    final cardsList = FileReader.readFromList(
        intList ?? Uint8List(0), deck);
    return cardsList;
  }

  /// Delete a list of deck from the Supabase storage.
  Future<bool> deleteDecks(List<String> deck) async {
    final response = await _supabase?.storage.from('decks').remove(deck);
    return response != null;
  }
}
