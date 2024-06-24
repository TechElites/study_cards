import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/data/model/deck.dart';
import 'package:flash_cards/theme/theme_provider.dart';
import 'package:flash_cards/src/screens/add/add_deck.dart';
import 'package:flash_cards/src/screens/home/cards_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DecksPage extends StatefulWidget {
  const DecksPage({super.key});

  @override
  State<DecksPage> createState() => _DecksPageState();
}

class _DecksPageState extends State<DecksPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final List<int> _deletionDecks = [];
  bool _deletionMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Decks'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ThemeProvider>(context).isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Deck>>(
        future: _dbHelper.getDecks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final deck = snapshot.data![index];
                  return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation:
                            _deletionDecks.contains(deck.id) ? 5 : 1,
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(deck.name),
                          selected: _deletionDecks.contains(deck.id),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total cards: ${deck.cards}'),
                              Text(
                                  'Creation date: ${deck.creation.toString().substring(0, 10)}'),
                            ],
                          ),
                          onTap: () {
                            if (_deletionMode) {
                              setState(() {
                                if (_deletionDecks.contains(deck.id)) {
                                  _deletionDecks.remove(deck.id);
                                  if (_deletionDecks.isEmpty) {
                                    _deletionMode = false;
                                  }
                                } else {
                                  _deletionDecks.add(deck.id);
                                }
                              });
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CardsPage(deckId: deck.id),
                              ),
                            ).then((value) => setState(() {}));
                          },
                          onLongPress: () {
                            setState(() {
                              _deletionDecks.add(deck.id);
                              _deletionMode = true;
                            });
                          },
                        ),
                      ));
                },
              ));
        },
      ),
      floatingActionButton: _deletionMode
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _deletionMode = false;
                  for (var deck in _deletionDecks) {
                    _dbHelper.deleteDeck(deck);
                  }
                  _deletionDecks.clear();
                });
              },
              tooltip: 'Delete Decks',
              child: const Icon(Icons.delete),
            )
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddDeck(),
                  ),
                ).then((value) => setState(() {}));
              },
              tooltip: 'Add Deck',
              child: const Icon(Icons.add),
            ),
    );
  }
}
