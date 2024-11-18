import 'package:study_cards/src/composables/ads/ads_scaffold.dart';
import 'package:study_cards/src/composables/floating_bar.dart';
import 'package:study_cards/src/data/remote/supabase_helper.dart';
import 'package:study_cards/src/logic/language/string_extension.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:study_cards/src/data/database/db_helper.dart';
import 'package:study_cards/src/data/model/card/study_card.dart';
import 'package:study_cards/src/data/model/deck/deck.dart';
import 'package:flutter/material.dart';
import 'package:study_cards/src/logic/load/file_reader.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Creates a page to handle the creation of a new deck
class AddDeck extends StatefulWidget {
  const AddDeck({super.key});

  @override
  State<AddDeck> createState() => _AddDeckState();
}

class _AddDeckState extends State<AddDeck> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _nameController = TextEditingController();
  List<StudyCard> frontsAndBacks = [StudyCard(front: '', back: '')];
  bool _loadingCards = false;

  final SupabaseHelper _supabaseHelper = SupabaseHelper();
  List<FileObject> sharedDecks = [];
  bool _sharedDecksLoaded = false;
  String _sharedDeck = '';

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _supabaseHelper.listDecks().then((decks) {
        setState(() {
          sharedDecks = decks;
          _sharedDecksLoaded = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext cx) {
    return AdsScaffold(
      appBar: AppBar(
        title: Text('add_deck'.tr(cx)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              showDialog(
                context: cx,
                builder: (context) {
                  return AlertDialog(
                    title: Text('how_to_format'.tr(cx)),
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text("format_instructions".tr(cx)),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('close'.tr(cx)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'deck_name'.tr(cx),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  setState(() => _loadingCards = true);
                  FileReader.readFile().then((value) {
                    setState(() {
                      frontsAndBacks = value;
                      _nameController.text = frontsAndBacks[0].front;
                      _sharedDeck = '';
                      _loadingCards = false;
                    });
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(kIsWeb ? 'pick_xml'.tr(cx) : 'pick_xml_or_zip'.tr(cx)),
                    const Icon(Icons.folder_copy_rounded),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              if (!kIsWeb)
                Text('shared_decks'.tr(cx),
                    style: Theme.of(cx).textTheme.bodyMedium),
              if (!_sharedDecksLoaded && !kIsWeb)
                Container(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: const LinearProgressIndicator())
              else
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: sharedDecks.length,
                    itemBuilder: (context, index) {
                      final shDeck = sharedDecks[index];
                      return Card(
                          child: ListTile(
                              title: Text(shDeck.name),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _supabaseHelper
                                      .deleteDecks([shDeck.name]).then((_) {
                                    setState(() {
                                      sharedDecks.removeAt(index);
                                    });
                                    if (!cx.mounted) return;
                                    FloatingBar.show('deck_deleted'.tr(cx), cx);
                                  });
                                },
                              ),
                              onTap: () {
                                setState(() => _loadingCards = true);
                                _supabaseHelper
                                    .downloadDeck(shDeck.name)
                                    .then((value) {
                                  setState(() {
                                    frontsAndBacks = value;
                                    _nameController.text =
                                        frontsAndBacks[0].front;
                                    _sharedDeck = shDeck.name
                                        .substring(shDeck.name.length - 4);
                                    _loadingCards = false;
                                  });
                                });
                              }));
                    },
                  ),
                ),
              if (_loadingCards)
                Container(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: const CircularProgressIndicator())
              else
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: frontsAndBacks.length,
                  itemBuilder: (context, index) {
                    final item = frontsAndBacks[index];
                    if (item.front != '') {
                      var first = 'question'.tr(cx);
                      var second = 'answer'.tr(cx);
                      if (index == 0) {
                        first = 'deck_name'.tr(cx);
                        second = 'number_of_cards'.tr(cx);
                      }
                      return ListTile(
                        title: Text('$first: ${item.front}'),
                        subtitle: Text('$second: ${item.back}'),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_nameController.text != '') {
            _addDeck().then((deckId) {
              if (frontsAndBacks.length > 1) {
                final List<StudyCard> cards = [];
                for (var card in frontsAndBacks.sublist(1)) {
                  cards.add(StudyCard(
                      deckId: deckId,
                      front: card.front,
                      back: card.back,
                      frontMedia: card.frontMedia,
                      backMedia: card.backMedia));
                }
                _dbHelper.insertDeckCards(cards);
              }
              if (!cx.mounted) return;
              Navigator.pop(cx, deckId);
            });
          }
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  /// Adds the deck to the database
  Future<int> _addDeck() {
    final Deck newDeck = Deck(
      name: _nameController.text,
      cards: frontsAndBacks.length - 1,
      creation: DateTime.now(),
      shared: _sharedDeck,
    );
    return _dbHelper.insertDeck(newDeck);
  }
}
