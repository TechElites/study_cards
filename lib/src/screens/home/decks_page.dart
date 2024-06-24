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
                      child: Row(children: [
                        ElevatedButton(
                          onPressed: () {
                            _dbHelper.deleteDeck(deck.id).then((_) {
                              setState(() {});
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(10),
                          ),
                          child: const Icon(Icons.delete),
                        ),
                        Expanded(
                            child: Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(deck.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total cards: ${deck.cards}'),
                                Text('Cards per review: ${deck.reviewCards}'),
                                Text(
                                    'Creation date: ${deck.creation.toString().substring(0, 10)}'),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CardsPage(deckId: deck.id),
                                ),
                              ).then((value) => setState(() {}));
                            },
                            onLongPress: () {
                              _changeDeckName(deck);
                            },
                          ),
                        ))
                      ]));
                },
              ));
        },
      ),
      floatingActionButton: FloatingActionButton(
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

  void _changeDeckName(Deck deck) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController nameController = TextEditingController();
        return AlertDialog(
          title: const Text('Change deck name'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: 'New deck name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _dbHelper
                    .updateDeckName(deck.id, nameController.text)
                    .then((_) {
                  setState(() {});
                  Navigator.pop(context);
                });
              },
              child: const Text('Change'),
            ),
          ],
        );
      },
    );
  }
}
