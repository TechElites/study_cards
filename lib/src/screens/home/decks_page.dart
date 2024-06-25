import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/data/model/deck.dart';
import 'package:flash_cards/src/logic/list_deleter.dart';
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
  final ListDeleter _deleter = ListDeleter();

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
                  return Dismissible(
                      key: Key(deck.id.toString()),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        _dbHelper.deleteDeck(deck.id).then((_) {
                          setState(() {
                            snapshot.data!.removeAt(index);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Deck ${deck.name} deleted')),
                          );
                        });
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            elevation: _deleter.isInList(deck.id) ? 5 : 1,
                            margin: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(deck.name),
                              selected: _deleter.isInList(deck.id),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total cards: ${deck.cards}'),
                                  Text(
                                      'Creation date: ${deck.creation.toString().substring(0, 10)}'),
                                ],
                              ),
                              onTap: () {
                                if (_deleter.isDeleting) {
                                  setState(() {
                                    _deleter.toggleItem(deck.id);
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
                                  _deleter.isDeleting = true;
                                  _deleter.toggleItem(deck.id);
                                });
                              },
                            ),
                          )));
                },
              ));
        },
      ),
      floatingActionButton: _deleter.isDeleting
          ? FloatingActionButton(
              onPressed: () {
                _dbHelper
                    .deleteDecks(_deleter.dumpList())
                    .then((value) => setState(() {}));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Decks deleted')),
                );
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
